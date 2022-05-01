// This file is part of Pokas.
//
// Pokas is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Pokas is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Pokas. If not, see <https://www.gnu.org/licenses/>.

// Package main contains the main code for the application.
package main

import (
	"log"
	"os"
	"time"

	"github.com/mitchellh/cli"
	"github.com/mundoalem/pokas/internal/command"
)

// The following values are set during build time through the linker flags.
// nolint:gochecknoglobals
var (
	// AppName is the name of current application.
	AppName = "pokas"
	// Commit is the hash of the commit used to build the current binary.
	Commit = "unknown"
	// BuildTime is a representation of the build process timestamp in RFC3339 format.
	BuildTime = time.Now().Format(time.RFC3339)
	// Version is the current version of the binary.
	Version = "dev"
)

// nolint:varnamelen
func main() {
	c := cli.NewCLI(AppName, Version)
	c.Args = os.Args[1:]

	c.Commands = map[string]cli.CommandFactory{
		"version": func() (cli.Command, error) {
			return &command.VersionCommand{
				Commit:    Commit,
				BuildTime: BuildTime,
				Version:   Version,
			}, nil
		},
	}

	exitStatus, err := c.Run()
	if err != nil {
		log.Println(err)
	}

	os.Exit(exitStatus)
}
