// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// LICENSE
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
// This file is part of pokas.
//
// The pokas is free software: you can redistribute it and/or modify it under the terms of the GNU Affero
// General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your
// option) any later version.
//
// The pokas is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the
// implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU Affero General Public License along with pokas. If not, see
// <https://www.gnu.org/licenses/>.
//
//
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

package main

import (
	"log"
	"os"
	"time"

	"github.com/mitchellh/cli"
	"github.com/mundoalem/pokas/internal/command"
)

var (
	// AppName is the name of current application.
	AppName string = "pokas"
	// Commit is the hash of the commit used to build the current binary.
	Commit string = "unknown"
	// BuildTime is a representation of the build process timestamp in RFC3339 format.
	BuildTime string = time.Now().Format(time.RFC3339)
	// Version is the current version of the binary.
	Version string = "dev"
)

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
