package main

import (
	"fmt"
	"log"
	"os"
	"path/filepath"
	"runtime"
	"sort"
	"time"

	"github.com/keegancsmith/counsel-repo/internal/fastwalk"
)

type Repo struct {
	// Name is the path relative to the src path.
	Name string

	// Path is the location of the repository.
	Path string

	// HEAD is the modtime of HEAD. Useful indicator of the last time a
	// repository was used. If we failed to find the modtime of HEAD, HEAD
	// will be the zero time instant.
	HEAD time.Time
}

func main() {
	// Same calculation done by fastwalk
	numWorkers := 4
	if n := runtime.NumCPU(); n > numWorkers {
		numWorkers = n
	}
	c := make(chan Repo, numWorkers*2) // extra buffering to avoid stalling a worker
	go func() {
		defer close(c)
		for _, srcpath := range os.Args[1:] {
			err := fastwalk.Walk(srcpath, func(path string, typ os.FileMode) error {
				if typ != os.ModeDir {
					return nil
				}

				if base := filepath.Base(path); len(base) > 0 && base[0] == '.' {
					return filepath.SkipDir
				}

				if _, err := os.Stat(filepath.Join(path, ".git")); os.IsNotExist(err) {
					return nil
				}

				name, err := filepath.Rel(srcpath, path)
				if err != nil {
					return err
				}

				var mod time.Time
				if info, err := os.Stat(filepath.Join(path, ".git/HEAD")); err == nil {
					mod = info.ModTime()
				}

				c <- Repo{
					Name: name,
					Path: path,
					HEAD: mod,
				}
				return filepath.SkipDir
			})
			if err != nil {
				log.Fatal(err)
			}
		}
	}()

	var repos []Repo
	for repo := range c {
		repos = append(repos, repo)
	}

	sort.Slice(repos, func(i, j int) bool {
		if repos[i].HEAD.Equal(repos[j].HEAD) {
			return repos[i].Path > repos[j].Path
		}
		return repos[i].HEAD.After(repos[j].HEAD)
	})

	for _, repo := range repos {
		fmt.Println(repo.Name)
	}
}
