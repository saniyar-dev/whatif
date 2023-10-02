package main

import (
	"os"

	"k8s.io/component-base/cli"
	"k8s.io/kubernetes/cmd/kube-scheduler/app"

	"github.com/saniyar-dev/whatif/pkg/exporter"
)

func main() {
	command := app.NewSchedulerCommand(app.WithPlugin(exporter.Name, exporter.New))

	code := cli.Run(command)
	os.Exit(code)
}
