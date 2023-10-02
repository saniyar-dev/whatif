package exporter

import (
	"context"
	"time"

	v1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/klog/v2"
	"k8s.io/kubernetes/pkg/scheduler/framework"
)

type Exporter struct {
	frameworkHandler framework.Handle
}

var _ framework.PermitPlugin = &Exporter{}

const (
	Name = "Exporter"
)

func New(obj runtime.Object, handle framework.Handle) (framework.Plugin, error) {
	plugin := &Exporter{
		frameworkHandler: handle,
	}

	return plugin, nil
}

func (e *Exporter) Name() string {
	return Name
}

func (e *Exporter) Permit(
	ctx context.Context,
	state *framework.CycleState,
	pod *v1.Pod,
	nodeName string,
) (*framework.Status, time.Duration) {
	waitTime := time.Second * 5
	var retStatus *framework.Status
	klog.Infof(`PodName: %s, NodeName: %s`, pod.GetName(), nodeName)

	retStatus = framework.NewStatus(framework.Success, "Test success")
	return retStatus, waitTime
}
