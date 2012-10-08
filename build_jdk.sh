#!/usr/bin/env bash

#########################################################

versions=(["6"]="http://hg.openjdk.java.net/jdk6/jdk6" 
          ["7"]="http://hg.openjdk.java.net/jdk7u/jdk7u" 
          ["8"]="http://hg.openjdk.java.net/jdk8/jdk8")

#########################################################

# download [6|7|8] [repo_directory]
download(){
  echo "===>> Download"
  cwd=$(pwd)
  
  if [ ! -d $2 ]; then echo "Directory does not exist: ${2}" ; return 1 ; fi
  url=${versions["$1"]}
  echo "Cloning ${url} to ${2}"
  hg clone ${url} ${2}
  if [ $? -ne 0 ]; then echo "Failed to clone ${url} repository." ; return 1 ; fi
  cd ${2} ; sh "./get_source.sh"
  if [ $? -ne 0 ]; then echo "Failed to get jdk sources" ; cd ${cwd} ; return 1 ; fi 
  
  cd ${cwd}
  echo "===>> Done."
  return 0
}

# prepare_env [6|7|8] [repo_directory]
prepare_env(){
  echo "===>> Setting build env"
  unset JAVA_HOME
  export LANG=C
  export ALLOW_DOWNLOADS=true
  export EXTRA_LIBS=/usr/lib/x86_64-linux-gnu/libasound.so
  export DISABLE_HOTSPOT_OS_VERSION_CHECK=ok
  source $2/jdk/make/jdk_generic_profile.sh
  echo "===>> Done."
  return 0
}

# build [repo_directory]
build(){
  echo "===>> Build"
  cwd=$(pwd)
  
  cd $1 ; make sanity
  if [ $? -ne 0 ]; then echo "Sanity check failed." ; cd ${cwd} ; return 1 ; fi 
  make 
  if [ $? -ne 0 ]; then echo "Build failed." ; cd ${cwd} ; return 1 ; fi
  
  cd ${cwd}
  echo "===>> Done."
  return 0
}

# create_jdk_archive [archive_file_name] [repo_directory]
create_jdk_archive(){
  echo "===>> Creating archive"
  cwd=$(pwd)

  jdkDir="${2}/build/$(get_build_dir_name ${2}/build/)/j2sdk-image/"
  if [ ! -d ${jdkDir} ]; then echo "Directory does not exist: ${jdkDir}" ; return 1 ; fi
  cd ${jdkDir} ; 
  tar -zcf "${cwd}/${1}" *
  if [ $? -ne 0 ]; then echo "Archive creation failed." ; cd ${cwd} ; return 1 ; fi
  
  cd ${cwd}
  echo "===>> Done."
  return 0;
}

# get_build_dir_name [jdk_build_directory] - not nice solution but does the job
get_build_dir_name(){
  echo $(ls ${1});
}

# for future use
get_platform(){
  OSNAME=$(uname -s)
  if [ ${OSNAME} = "Linux" ]; then
    echo "linux"
  elif [ ${OSNAME} = "Darwin" ]; then
    echo "bsd"
  else
    echo "unsupported"
  fi
}

# for future use
get_architecture(){
  echo "amd64"
}

# do_all [6|7|8] [directory]
do_all(){
  repoDir="${2}/${1}"
  if [ ! -d $2 ]; then echo "Directory does not exist: ${2}" ; return 1 ; fi
  mkdir -p ${repoDir}
  download $1 ${repoDir}
  if [ $? -ne 0 ]; then return 1 ; fi
  prepare_env ${1} ${repoDir}
  if [ $? -ne 0 ]; then return 1 ; fi
  build ${repoDir}
  if [ $? -ne 0 ]; then return 1 ; fi
  create_jdk_archive "${2}/openjdk${1}.tar.gz" ${repoDir}
}

do_all $1 $2;
