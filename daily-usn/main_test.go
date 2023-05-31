package main

import "testing"

func TestProcess(t *testing.T) {
	result, err := generateReportEntries("test/01-old", "test/01-new")
	if err != nil {
		t.Fatal(err)
	}
	if len(result) != 3 {
		t.Fatal("Invalid length of the result")
	}
	if result[0].ArtifactName != "quay.io/cybozu/ubuntu:18.04.20230427" ||
		result[1].ArtifactName != "quay.io/cybozu/ubuntu:20.04.20230427" ||
		result[2].ArtifactName != "quay.io/cybozu/ubuntu:22.04.20230427" {
		t.Fatal("Invalid ArtifactName")
	}
	if len(result[0].AllVuls) != 1 || len(result[0].DiffVuls) != 1 ||
		len(result[1].AllVuls) != 1 || len(result[1].DiffVuls) != 1 ||
		len(result[2].AllVuls) != 1 || len(result[2].DiffVuls) != 1 {
		t.Fatal("Invalid length of AllVuls and/or DiffVuls")
	}
}
