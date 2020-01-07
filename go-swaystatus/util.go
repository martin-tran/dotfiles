package main

import (
	"bufio"
	"log"
	"os/exec"
	"time"
)

func TruncateUtf8(s string, length int) string {
	r := []rune(s)
	if len(r) > length {
		return string(r[:length])
	}
	return s
}

// SingleCommand runs a single *nix command and returns the first line of output
// as a string. If an error occurs, the string will be the empty string.
func SingleCommand(cmd *exec.Cmd) (string, error) {
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		log.Println(cmd, err)
		return "", err
	}
	if err := cmd.Start(); err != nil {
		log.Println(err)
		return "", err
	}

	scanner := bufio.NewScanner(stdout)
	scanner.Scan()
	return scanner.Text(), nil
}

// LoopCommand runs the given *nix command every |interval| milliseconds,
// sending the output of the command through the |info| channel.
func LoopCommand(cmd *exec.Cmd, interval time.Duration, info chan string) {
	for {
		res, err := SingleCommand(cmd)
		if err != nil {
			log.Println(err)
			info <- "ERR"
		} else {
			info <- res
		}
		time.Sleep(interval)
	}
}
