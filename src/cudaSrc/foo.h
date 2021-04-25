#pragma once
#include <vector>

#include <thrust/host_vector.h>
#include <thrust/device_vector.h>

#include <iostream>

struct Anchor
{
    int w{};
    int h{};
};

std::vector<Anchor> useCUDA(int size);

void test();