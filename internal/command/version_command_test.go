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

// Package command provides all the commands used by the main function
package command_test

import (
	"strings"
	"testing"

	"github.com/mundoalem/pokas/internal/command"
)

func TestVersionCommand_Help(t *testing.T) {
	t.Parallel()

	cmd := command.VersionCommand{} // nolint: exhaustivestruct

	if msg := strings.TrimSpace(cmd.Help()); msg == "" {
		t.Log("Help() should not return an empty string", msg)
		t.Fail()
	}
}

func TestVersionCommand_Run(t *testing.T) {
	t.Parallel()

	cmd := command.VersionCommand{} // nolint: exhaustivestruct

	if ret := cmd.Run([]string{}); ret != 0 {
		t.Log("Run() returned a value different than 0")
		t.Fail()
	}
}

func TestVersionCommand_Synopsis(t *testing.T) {
	t.Parallel()

	cmd := command.VersionCommand{} // nolint: exhaustivestruct

	if msg := strings.TrimSpace(cmd.Synopsis()); msg == "" {
		t.Log("Synopsis() should not return an empty string", msg)
		t.Fail()
	}
}
