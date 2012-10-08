##Supported OS: 

* Ubuntu

##Install dependencies:

* Ubuntu:

		apt-get install mercurial ant gawk g++ libcups2-dev libasound2-dev libfreetype6-dev libx11-dev libxt-dev libxext-dev libxrender-dev libxtst-dev libfontconfig1-dev lesstif2-dev

##Build:

* Ubuntu:

	`export ALT_BOOTDIR=[JAVA_COMPILER_DIR]`
	`build_jdk.sh [VERSION] [DIRECTORY_TO_STORE]`

##Example:

* Ubuntu:

	`export ALT_BOOTDIR=/usr/lib/jvm/java-6-openjdk ; mkdir openjdk ; build_jdk.sh 7 openjdk`


