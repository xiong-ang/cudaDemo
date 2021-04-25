TEMPLATE = app
CONFIG += console debug_and_release warn_on c++11
QT -= gui

win32 {
    QMAKE_CXXFLAGS += /MP /utf-8
}

	
unix {
	VERSION = 1.0.0
	QMAKE_CFLAGS += -fvisibility=hidden
	QMAKE_CXXFLAGS += -fvisibility=hidden -fvisibility-inlines-hidden
}

QMAKE_CXXFLAGS_RELEASE += $$QMAKE_CFLAGS_RELEASE_WITH_DEBUGINFO
QMAKE_LFLAGS_RELEASE   += $$QMAKE_LFLAGS_RELEASE_WITH_DEBUGINFO

Debug:{
	TARGET = cudaDemoD
	DESTDIR  = ./build/debug
	TEMP_DESTDIR = ./build/intermediate/debug/$$TARGET
	
}
Release:{
	TARGET = cudaDemo
	DESTDIR  = ./build/release
	TEMP_DESTDIR = ./build/intermediate/release/$$TARGET
}


MOC_DIR         = $$TEMP_DESTDIR/moc
RCC_DIR         = $$TEMP_DESTDIR/rcc
UI_DIR          = $$TEMP_DESTDIR/qui
OBJECTS_DIR     = $$TEMP_DESTDIR/obj

win32 {
	LIBS += \
		-L./third_party/TensorRT/lib nvinfer.lib nvinfer_plugin.lib \
		-L./third_party/cuda/lib/x64/ cuda.lib cudart.lib

	CONFIG(debug,debug|release){
		LIBS += -L./third_party/opencv/x64/vc14/lib opencv_imgproc346d.lib opencv_imgcodecs346d.lib opencv_core346d.lib opencv_dnn346d.lib
	}
	CONFIG(release,debug|release){
		LIBS += -L./third_party/opencv/x64/vc14/lib opencv_imgproc346.lib opencv_imgcodecs346.lib opencv_core346.lib opencv_dnn346.lib
	}
}

unix {
	LIBS += \
		-lnvinfer -lnvinfer_plugin \
		-L/usr/local/opencv/lib -lopencv_imgproc -lopencv_imgcodecs -lopencv_core -lopencv_dnn \
		-L/usr/local/cuda/lib64 -lcuda -lcudart \
		-lstdc++fs
}

win32 {
	INCLUDEPATH  +=  \
		./third_party/TensorRT/include  \
		./third_party/cuda/include \
		./third_party/opencv/include
}

unix {
	INCLUDEPATH  +=  \
		/usr/local/cuda/include \
		/usr/local/opencv/include
}

HEADERS += \
	src/cudaSrc/foo.h
	
SOURCES +=  \
    src/main.cpp
	
# CUDA settings
CUDA_SOURCES += \
	src/cudaSrc/foo.cu

win32 {
	SYSTEM_NAME = x64                 
	SYSTEM_TYPE = 64                  
	CUDA_ARCH = compute_35
	CUDA_CODE = sm_35
	CUDA_INC = $$join(INCLUDEPATH,'" -I"','-I"','"')
	MSVCRT_LINK_FLAG_DEBUG   = "/MDd"
	MSVCRT_LINK_FLAG_RELEASE   = "/MD"
	# Configuration of the Cuda compiler
	CONFIG(debug, debug|release) {
		# Debug mode
		cuda.input = CUDA_SOURCES
		cuda.output = $$OBJECTS_DIR/${QMAKE_FILE_BASE}_cuda.obj
		cuda.commands = $$PWD/./third_party/cuda/bin/nvcc.exe -D_DEBUG -Xcompiler $$MSVCRT_LINK_FLAG_DEBUG -c -Xcompiler $$join(QMAKE_CXXFLAGS,",") $$join(INCLUDEPATH,'" -I "','-I "','"') ${QMAKE_FILE_NAME} -o ${QMAKE_FILE_OUT}
		QMAKE_EXTRA_COMPILERS += cuda
	} else {
		# Release mode
		cuda.input = CUDA_SOURCES
		cuda.output = $$OBJECTS_DIR/${QMAKE_FILE_BASE}_cuda.obj
		cuda.commands = $$PWD/./third_party/cuda/bin/nvcc.exe -Xcompiler $$MSVCRT_LINK_FLAG_RELEASE -c -Xcompiler $$join(QMAKE_CXXFLAGS,",") $$join(INCLUDEPATH,'" -I "','-I "','"') ${QMAKE_FILE_NAME} -o ${QMAKE_FILE_OUT}
		QMAKE_EXTRA_COMPILERS += cuda
	}
}

unix {
	CUDA_SDK = "/usr/local/cuda"   # Path to cuda SDK install
	CUDA_DIR = "/usr/local/cuda"   # Path to cuda toolkit install
	SYSTEM_NAME = linux            # Depending on your system either 'Win32', 'x64', or 'Win64'
	SYSTEM_TYPE = 64               # '32' or '64', depending on your system
	CUDA_ARCH = compute_35         # Type of CUDA architecture, for example 'compute_10', 'compute_11', 'sm_10'
	CUDA_CODE = sm_35              # 
	NVCC_OPTIONS = --use_fast_math -Xcompiler -fPIC


	# INCLUDEPATH += $$CUDA_DIR/include
	QMAKE_LIBDIR += $$CUDA_DIR/lib64/

	CUDA_INC = $$join(INCLUDEPATH,'" -I"','-I"','"')
	NVCC_LIBS = $$LIBS

	CONFIG(debug, debug|release) {
    	# Debug mode
		cuda_d.input = CUDA_SOURCES
		cuda_d.output = $$OBJECTS_DIR/${QMAKE_FILE_BASE}_cuda.o
		cuda_d.commands = $$CUDA_DIR/bin/nvcc -D_DEBUG $$NVCC_OPTIONS $$CUDA_INC $$NVCC_LIBS --machine $$SYSTEM_TYPE -arch=$$CUDA_ARCH -c -o ${QMAKE_FILE_OUT} ${QMAKE_FILE_NAME}
		# cuda_d.dependency_type = TYPE_C
		QMAKE_EXTRA_COMPILERS += cuda_d
	} else {
		# Release mode
		cuda.input = CUDA_SOURCES
		cuda.output = $$OBJECTS_DIR/${QMAKE_FILE_BASE}_cuda.o
		cuda.commands = $$CUDA_DIR/bin/nvcc $$NVCC_OPTIONS $$CUDA_INC $$NVCC_LIBS --machine $$SYSTEM_TYPE -arch=$$CUDA_ARCH -O3 -c -o ${QMAKE_FILE_OUT} ${QMAKE_FILE_NAME}
		# cuda.dependency_type = TYPE_C
		QMAKE_EXTRA_COMPILERS += cuda
	}
}
