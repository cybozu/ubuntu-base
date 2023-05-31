package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"text/template"
)

type TrivyJSONResultVulnerability struct {
	VulnerabilityID  string
	PkgID            string
	PkgName          string
	InstalledVersion string
	FixedVersion     string
	Layer            map[string]string
	SeveritySource   string
	PrimaryURL       string
	DataSource       map[string]string
	Title            string
	Description      string
	Severity         string
	CweIDs           []string
	CVSS             map[string]interface{}
	References       []string
	PublishedDate    string
	LastModifiedData string
}

type TrivyJSONResult struct {
	Vulnerabilities []TrivyJSONResultVulnerability
}

type TrivyJSON struct {
	SchemaVersion int
	ArtifactName  string
	Results       []TrivyJSONResult
}

type Vulnerability struct {
	PkgID            string
	PkgName          string
	InstalledVersion string
	FixedVersion     string
	ID               string
	USN              string
	PrimaryUrl       string
	USNUrl           string
	Title            string
	Description      string
	Severity         string
}

type ReportEntry struct {
	ArtifactName string
	DiffVuls     []*Vulnerability
	AllVuls      []*Vulnerability
	RawTrivyJSON string
}

func fetchUSNFromCVE(cveId string) (string, error) {
	url, err := url.JoinPath("https://ubuntu.com/security/cves/", cveId+".json")
	if err != nil {
		return "", err
	}
	log.Printf("GET %s\n", url)
	resp, err := http.Get(url)
	if err != nil {
		return "", err
	}
	dec := json.NewDecoder(resp.Body)
	body := map[string]interface{}{}
	if err := dec.Decode(&body); err != nil {
		return "", err
	}
	notices, ok := body["notices"].([]interface{})
	if !ok {
		return "", errors.New("Invalid JSON")
	}
	usn := ""
	for _, rawNotice := range notices {
		notice := rawNotice.(map[string]interface{})

		typ, ok := notice["type"].(string)
		if !ok || typ != "USN" {
			continue
		}
		usn, ok = notice["id"].(string)
		if !ok {
			continue
		}
		break
	}
	if usn == "" {
		return "", errors.New("USN not found")
	}
	return usn, nil
}

func NewVulnerability(j *TrivyJSONResultVulnerability) *Vulnerability {
	id := j.VulnerabilityID
	PrimaryUrl := "https://nvd.nist.gov/vuln/detail/" + id

	usnId, err := fetchUSNFromCVE(id)
	if err != nil {
		log.Printf("Couldn't fetch USN from CVE: %s: %v", id, err)
	}
	usnLink := ""
	if usnId != "" {
		usnLink = "https://ubuntu.com/security/notices/" + usnId
	}

	return &Vulnerability{
		PkgID:            j.PkgID,
		PkgName:          j.PkgName,
		InstalledVersion: j.InstalledVersion,
		FixedVersion:     j.FixedVersion,
		ID:               id,
		USN:              usnId,
		PrimaryUrl:       PrimaryUrl,
		USNUrl:           usnLink,
		Title:            j.Title,
		Description:      j.Description,
		Severity:         j.Severity,
	}
}

func parseTrivyJSON(reader io.Reader) (*TrivyJSON, error) {
	dec := json.NewDecoder(reader)
	var res TrivyJSON
	if err := dec.Decode(&res); err != nil {
		return nil, err
	}
	return &res, nil
}

func diffVulnerabilities(oldVuls []*Vulnerability, newVuls []*Vulnerability) []*Vulnerability {
	m := map[string]*Vulnerability{}
	for _, v := range oldVuls {
		m[v.ID+v.PkgID] = v
	}

	res := []*Vulnerability{}
	for _, v := range newVuls {
		_, ok := m[v.ID+v.PkgID]
		if !ok {
			res = append(res, v)
		}
	}

	return res
}

func diffTrivyVulnerabilities(oldVuls []TrivyJSONResultVulnerability, newVuls []TrivyJSONResultVulnerability) []TrivyJSONResultVulnerability {
	m := map[string]TrivyJSONResultVulnerability{}
	for _, v := range oldVuls {
		m[v.VulnerabilityID+v.PkgID] = v
	}

	res := []TrivyJSONResultVulnerability{}
	for _, v := range newVuls {
		_, ok := m[v.VulnerabilityID+v.PkgID]
		if !ok {
			res = append(res, v)
		}
	}

	return res
}

func loadTrivyJSON(fileName string) (*TrivyJSON, error) {
	file, err := os.Open(fileName)
	if err != nil {
		log.Printf("Couldn't open file (%s, %s). Treated as no results.", fileName, err)
		return nil, nil
	}
	defer file.Close()

	j, err := parseTrivyJSON(file)
	if err != nil {
		return nil, err
	}

	if len(j.Results) != 1 {
		return nil, fmt.Errorf("Invalid # of JSON results: %d", len(j.Results))
	}

	return j, nil
}

func ConvertTrivyVulsToVuls(trivyVuls []TrivyJSONResultVulnerability) []*Vulnerability {
	vuls := []*Vulnerability{}
	for _, trivyVul := range trivyVuls {
		vul := NewVulnerability(&trivyVul)
		vuls = append(vuls, vul)
	}
	return vuls
}

func generateHTML(reportId string, entries []ReportEntry) (string, error) {
	const tpl = `
{{ define "vultable" }}
<table>
<thead>
    <tr>
        <th>Package Name</th>
        <th>Vulnerability ID</th>
        <th>USN ID</th>
        <th>Severity</th>
        <th>Installed Version </th>
        <th>Fixed Version</th>
        <th>Title</th>
    </tr>
</thead>
<tbody>
{{ range . }}
<tr class="severity-{{ .Severity }}">
    <td>{{ .PkgName }}</td>
    <td><a href="{{ .PrimaryUrl }}" target="_blank" rel="noopener noreferrer">{{ .ID }}</a></td>
    <td><a href="{{ .USNUrl }}" target="_blank" rel="noopener noreferrer">{{ .USN }}</a></td>
    <td>{{ .Severity }}</td>
    <td>{{ .InstalledVersion }}</td>
    <td>{{ .FixedVersion }}</td>
    <td>{{ .Title }}</td>
</tr>
{{ end }}
</tbody>
</table>
{{ end }}
{{/* ======================== */}}
<html>
<head>
<title>daily-usn</title>
<style>
{{/* Thanks to: https://github.com/aquasecurity/trivy/blob/72e302cf818cbb2c983c64a3929778b0b25ccb1d/contrib/html.tpl */}}
* {
    font-family: Arial, Helvetica, sans-serif;
}
h1, h2, h3 {
    text-align: center;
}
.group-header th {
    font-size: 200%;
}
.sub-header th {
    font-size: 150%;
}
table, th, td {
    border: 1px solid black;
    border-collapse: collapse;
    white-space: nowrap;
    padding: .3em;
}
table {
    margin: 0 auto;
}
.severity {
    text-align: center;
    font-weight: bold;
    color: #fafafa;
}
.severity-LOW .severity { background-color: #5fbb31; }
.severity-MEDIUM .severity { background-color: #e9c600; }
.severity-HIGH .severity { background-color: #ff8800; }
.severity-CRITICAL .severity { background-color: #e40000; }
.severity-UNKNOWN .severity { background-color: #747474; }
.severity-LOW { background-color: #5fbb3160; }
.severity-MEDIUM { background-color: #e9c60060; }
.severity-HIGH { background-color: #ff880060; }
.severity-CRITICAL { background-color: #e4000060; }
.severity-UNKNOWN { background-color: #74747460; }
table tr td:first-of-type {
    font-weight: bold;
}
</style>
</head>
<body>
<h1>Daily Vulnerability Report ({{ .ReportId }})</h1>
{{/* ======================== */}}
{{ range .Entries }}
<h2>{{ .ArtifactName }}</h2>
<h3>New vulnerabilities appeared in this run</h3>
{{ template "vultable" .DiffVuls }}
<h3>All vulnerabilities found by Trivy</h3>
<center>
<details>
<summary>Click here to unfold</summary>
{{ template "vultable" .AllVuls }}
</details>
</center>
{{ end }}
{{/* ======================== */}}
</body>
</html>
`

	t, err := template.New("webpage").Parse(tpl)
	if err != nil {
		return "", err
	}
	data := struct {
		ReportId string
		Entries  []ReportEntry
	}{
		ReportId: reportId,
		Entries:  entries,
	}
	b := bytes.Buffer{}
	if err := t.Execute(&b, data); err != nil {
		return "", err
	}

	return b.String(), nil
}

func generateReportEntries(trivyResultOldDir string, trivyResultDir string) ([]ReportEntry, error) {
	newFiles, err := os.ReadDir(trivyResultDir)
	if err != nil {
		return nil, err
	}

	reportEntries := []ReportEntry{}
	for _, file := range newFiles {
		fileName := file.Name()

		newFilePath := filepath.Join(trivyResultDir, fileName)
		oldFilePath := filepath.Join(trivyResultOldDir, fileName)
		log.Printf("new_file_path = %s\n", newFilePath)
		log.Printf("old_file_path = %s\n", oldFilePath)

		newResults, err := loadTrivyJSON(newFilePath)
		if err != nil {
			return nil, err
		}
		oldResults, err := loadTrivyJSON(oldFilePath)
		if err != nil {
			return nil, err
		}
		oldVuls := []TrivyJSONResultVulnerability{}
		if oldResults != nil {
			oldVuls = oldResults.Results[0].Vulnerabilities
		}
		diffTrivyVuls := diffTrivyVulnerabilities(oldVuls, newResults.Results[0].Vulnerabilities)
		rawTrivyJSON, err := os.ReadFile(newFilePath)
		if err != nil {
			return nil, err
		}

		reportEntry := ReportEntry{
			ArtifactName: newResults.ArtifactName,
			AllVuls:      ConvertTrivyVulsToVuls(newResults.Results[0].Vulnerabilities),
			DiffVuls:     ConvertTrivyVulsToVuls(diffTrivyVuls),
			RawTrivyJSON: string(rawTrivyJSON),
		}
		reportEntries = append(reportEntries, reportEntry)
	}

	return reportEntries, nil
}

func process(reportId string, trivyResultOldDir string, trivyResultDir string) error {
	reportEntries, err := generateReportEntries(trivyResultOldDir, trivyResultDir)
	if err != nil {
		return err
	}
	html, err := generateHTML(reportId, reportEntries)
	if err != nil {
		return err
	}
	fmt.Print(html)

	return nil
}

func main() {
	if len(os.Args) != 4 {
		log.Fatal("Usage: daily-usn REPORT-ID OLD-RESULT-DIR NEW-RESULT-DIR")
	}
	err := process(os.Args[1], os.Args[2], os.Args[3])
	if err != nil {
		log.Fatal(err)
	}
}
