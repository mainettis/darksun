#MODULE_NAME - name of the module as input into
#   the nasher.cfg [Target].  To allow changes
#   without modifying addition files, the module
#   will always be built as "ds.mod".  Can be passed
#   as an argument from docker-compose
ARG MODULE_NAME=ds-development

#UNIFIED_BUILD - the build to use for nwserver.
#   Can be passed as an argument from docker-compose, 
#   so if there are issues with an update, switch back 
#   to a previous build.
ARG UNIFIED_BUILD=build8193.12

#NASHER_TARGET - the [Target] name from the repo's
#   nasher.cfg file.  This allows a build without having
#   to flatten the directory structure and keeps the
#   docker build efficient.  Can be pass as an argument
#   from docker-compose.
ARG NASHER_TARGET=ds

#Build the module from the git repository.
#   The repository's .dockerignore file is respected in the 
#   ADD command and greatly reduces the scope and context of
#   the docker build, so keep it updated!
FROM squattingmonk/nasher:latest AS module
ARG NASHER_TARGET
ADD . /nasher
RUN nasher pack ${NASHER_TARGET} --yes

#Get the nwserver running
ARG UNIFIED_BUILD
FROM nwnxee/unified:${UNIFIED_BUILD}
ARG MODULE_NAME
COPY --from=module /nasher/${MODULE_NAME}.mod /nwn/data/data/mod/ds.mod
RUN rm /nwn/data/data/mod/DockerDemo.mod 
    #&& apt-get update && apt-get install -y apt-utils libgdiplus libc6-dev

#The following environmental variables are set by nwnxee/unified
#ENV NWNX_CORE_LOAD_PATH=/nwn/nwnx/
#ENV NWN_LD_PRELOAD="/nwn/nwnx/NWNX_Core.so"
#ENV NWNX_SERVERLOGREDIRECTOR_SKIP=n \
#    NWN_TAIL_LOGS=n \
#    NWNX_CORE_LOG_LEVEL=6 \
#    NWNX_SERVERLOGREDIRECTOR_LOG_LEVEL=6
#ENV NWNX_CORE_SKIP_ALL=y

#The remaining environmental variables are set in ../../config/nwserver.env
#to keep the build efficient.
