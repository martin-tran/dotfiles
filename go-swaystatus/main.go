package main

import (
	"fmt"
	"log"
	"os/exec"
	"time"

	"go.i3wm.org/i3"
)

const (
	CpuCores    = 8
	CpuInterval = 5 * time.Minute
	MpdInterval = 5 * time.Second
	BatInterval = 5 * time.Minute
	IdenLen     = 6
)

func WatchWindows(info chan string) {
	recv := i3.Subscribe(i3.WindowEventType)
	for recv.Next() {
		ev := recv.Event().(*i3.WindowEvent)
		if ev.Change == "focus" {
			if focused := ev.Container.FindFocused(func(node *i3.Node) bool {
				return node.Focused
			}); focused != nil {
				info <- focused.Name
			}
		}
	}
	log.Fatal(recv.Close())
}

// WatchTicks subscribes to sway tick events to monitor changes to ALSA volume
// levels, display backlight levels, and the status of the idle inhibitor when
// those changes are triggered by use of the keybinds in the sway config file.
// It is expected that that the payloads sent by those keybinds start with a
// 5 character long identifer {'volum' 'light', 'inhib'} followed by a space,
// and then the current value of whatever it is.
// The payloads for volume and light levels should include the '%' symbol.
// Volume can also have the payload of 'volum mute' if ALSA was just muted.
func WatchTicks(volInfo, lightInfo, inhibInfo chan string) {
	recv := i3.Subscribe(i3.TickEventType)
	for recv.Next() {
		ev := recv.Event().(*i3.TickEvent)
		if len(ev.Payload) > IdenLen {
			log.Printf("payload: %s", ev.Payload)
			if ev.Payload[:IdenLen] == "volum " {
				volInfo <- ev.Payload[IdenLen:]
			} else if ev.Payload[:IdenLen] == "light " {
				lightInfo <- ev.Payload[IdenLen:]
			} else if ev.Payload[:IdenLen] == "inhib " {
				inhibInfo <- ev.Payload[IdenLen:]
			}
		}
	}
	log.Fatal(recv.Close())
}

func WatchCpu(info chan string) {
	rawInfo := make(chan string)
	go LoopCommand(exec.Command("/home/thereca/.config/common_utils.sh", "get_cpu_load"), CpuInterval, rawInfo)

	for raw := range rawInfo {
		var avg float64
		fmt.Sscanf(raw, "%f,", &avg)
		info <- fmt.Sprintf("%.0f%%", (avg*100)/CpuCores)
	}
}

func PrintBar(f, m, c, v, l, b, i string) {
	fmt.Printf("%s \t\t\t\t | %s | CPU:%s | VOL:%s | LIGHT:%s | BAT:%s | INHIB:%s |\n", f, m, c, v, l, b, i)
}

func main() {
	initSway()

	focusInfo := make(chan string)
	mpdInfo := make(chan string)
	cpuInfo := make(chan string)
	volInfo := make(chan string)
	lightInfo := make(chan string)
	batInfo := make(chan string)
	inhibInfo := make(chan string)

	go WatchWindows(focusInfo)
	go LoopCommand(exec.Command("mpc"), MpdInterval, mpdInfo)
	go WatchCpu(cpuInfo)
	go LoopCommand(exec.Command("/home/thereca/.config/common_utils.sh", "get_battery"), BatInterval, batInfo)
	go WatchTicks(volInfo, lightInfo, inhibInfo)

	f := ""
	m, _ := SingleCommand(exec.Command("mpc"))
	c := "0%"
	v := initVol()
	l := initLight()
	b, _ := SingleCommand(exec.Command("/home/thereca/.config/common_utils.sh", "get_battery"))
	i := "OFF"

	for {
		select {
		case f = <-focusInfo:
			PrintBar(f, m, c, v, l, b, i)
		case m = <-volInfo:
			PrintBar(f, m, c, v, l, b, i)
		case c = <-cpuInfo:
			PrintBar(f, m, c, v, l, b, i)
		case v = <-volInfo:
			PrintBar(f, m, c, v, l, b, i)
		case l = <-lightInfo:
			PrintBar(f, m, c, v, l, b, i)
		case b = <-lightInfo:
			PrintBar(f, m, c, v, l, b, i)
		case i = <-inhibInfo:
			PrintBar(f, m, c, v, l, b, i)
		default:
			time.Sleep(250 * time.Millisecond)
		}

	}
}
