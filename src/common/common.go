package common

import (
	"log"
	"os"
	"strings"
)

func GetProjectDir() string {
	wd, err := os.Getwd()
	if err != nil {
		log.Fatalf("Unable to get project working directory")
	}
	paths := strings.Split(wd, "/")
	i := 0
	j := 0
	for i = 0; i < len(paths); i++ {
		cur := paths[i]
		if cur == "leo" {
			if i < len(paths)-1 {
				j = i + 1
				break
			} else {
				j = i
				break
			}
		}
	}
	return strings.Join(paths[0:j], "/")
}

func ProjectRelativePath(relative_path string) string {
	return GetProjectDir() + "/" + relative_path
}

// Linux Cd command
func Cd(path string) string {
	paths := strings.Split(path, "/")
	return strings.Join(paths[0:len(paths)-1], "/")
}
