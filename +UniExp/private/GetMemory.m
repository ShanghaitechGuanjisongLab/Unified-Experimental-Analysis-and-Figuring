function [ParallelMemory,CpuMemory] = GetMemory
GpuMemory=zeros(gpuDeviceCount,1);
spmd
	if labindex>gpuDeviceCount
		gpuDevice([]);
	else
		GpuMemory(labindex)=gpuDevice(labindex).AvailableMemory;
	end
end
[~,SystemView]=memory;
CpuMemory=SystemView.PhysicalMemory.Available;
ParallelMemory=min([GpuMemory;CpuMemory/gcp().NumWorkers]);