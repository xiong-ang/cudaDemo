#include <stdio.h>
#include <iostream>
#include "cudaSrc\foo.h"

int main()
{
    std::cout<<"Hello C++"<<std::endl;
    std::vector<Anchor> values = useCUDA(20);
    for (auto && v : values)
    {
        std::cout << v.w << " " << v.h << std::endl;
    }

    test();

    return 0;
}
