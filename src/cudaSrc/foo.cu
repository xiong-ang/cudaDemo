#include "foo.h"

#define CHECK(res) { if(res != cudaSuccess){printf("Error ：%s:%d , ", __FILE__,__LINE__);   \
printf("code : %d , reason : %s \n", res,cudaGetErrorString(res));exit(-1);}}


__global__ void foo(Anchor *pData)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	((Anchor *)(pData + i))->w = i;
	((Anchor *)(pData + i))->h = i * i;

	int test[100]{};
	test[99] = i * i;

    printf("CUDA! %d\n", test[99]);
}

std::vector<Anchor> useCUDA(int size)
{
    Anchor *pData;
	cudaMallocManaged(&pData, sizeof(Anchor) * size);
    foo<<<1,size>>>(pData);
    CHECK(cudaDeviceSynchronize());

	std::vector<Anchor> result(pData, pData + size);
	cudaFree(pData);

	return result;
}

std::vector<Anchor> useCUDA2(int size)
{
    Anchor *gpuData;
	cudaMalloc(&gpuData, sizeof(Anchor) * size);
    foo<<<1,size>>>(gpuData);
    CHECK(cudaDeviceSynchronize());

	Anchor *cpuData = new Anchor[size];
	cudaMemcpyAsync(cpuData, gpuData, sizeof(Anchor)*size, cudaMemcpyDeviceToHost);
	cudaFree(gpuData);

	std::vector<Anchor> result(cpuData, cpuData + size);
	delete[] cpuData;

	return result;
}


void test()
{
	// H has storage for 4 integers
    thrust::host_vector<int> H(4);

    // initialize individual elements
    H[0] = 14;
    H[1] = 20;
    H[2] = 38;
    H[3] = 46;

    // H.size() returns the size of vector H
    std::cout << "H has size " << H.size() << std::endl;

    // print contents of H
    for (int i = 0; i < H.size(); i++)
        std::cout << "H[" << i << "] = " << H[i] << std::endl;

    // resize H
    H.resize(2);

    std::cout << "H now has size " << H.size() << std::endl;

    // Copy host_vector H to device_vector D
    thrust::device_vector<int> D = H;

    // elements of D can be modified
    D[0] = 99;
    D[1] = 88;

    // print contents of D
    for (int i = 0; i < D.size(); i++)
        std::cout << "D[" << i << "] = " << D[i] << std::endl;
}