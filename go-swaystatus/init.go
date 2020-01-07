package main

import (
	"bytes"
	"fmt"
	"log"
	"os/exec"

	"go.i3wm.org/i3"
)

// initSway sets the hooks for the i3 lib to talk to swaywm.
// Function contents copy-pasted from:
// https://github.com/dlasky/sway-wallhaven/blob/master/main.go
func initSway() {
	//i3 overrides to work with sway
	i3.SocketPathHook = func() (string, error) {
		out, err := exec.Command("sway", "--get-socketpath").CombinedOutput()
		if err != nil {
			return "", fmt.Errorf("getting sway socketpath: %v (output: %s)", err, out)
		}
		return string(out), nil
	}

	i3.IsRunningHook = func() bool {
		out, err := exec.Command("pgrep", "-c", "sway\\$").CombinedOutput()
		if err != nil {
			log.Printf("sway running: %v (output: %s)", err, out)
		}
		return bytes.Compare(out, []byte("1")) == 0
	}
}

func initVol() string {
	res, err := SingleCommand(exec.Command("/home/thereca/.config/common_utils.sh", "get_alsa_volume"))
	if err != nil {
		log.Println(err)
		return "ERR"
	} else {
		return res
	}
}

func initLight() string {
	res, err := SingleCommand(exec.Command("/home/thereca/.config/common_utils.sh", "get_backlight"))
	if err != nil {
		log.Println(err)
		return "ERR"
	} else {
		return res[IdenLen:]
	}
}
