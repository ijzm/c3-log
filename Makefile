CC        := c3c
TARGET    := log
BUILD_DIR := build/

SRC_DIR  := src/

SOURCES  += log/log.c3
SOURCES  += main.c3

SOURCES_FULL = ${addprefix ${SRC_DIR}, ${SOURCES}}

LIB_DIR  := 
LIBS     := 

CC_FLAGS := ${LIB_DIR} ${LIBS} --trust=include


default: run

run: ${BUILD_DIR}${TARGET}
	./${BUILD_DIR}${TARGET}

clean:
	${RM} ${BUILD_DIR}*

${BUILD_DIR}${TARGET}: ${SOURCES_FULL}
	${CC} compile ${SOURCES_FULL} ${CC_FLAGS} -o ${BUILD_DIR}${TARGET}