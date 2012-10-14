this project has to be built through the script release.sh or ant with build.xml
the script includes all needed assets from external project 'www'
in folder www/www

Please before of all adjust the following paths to your local environment

- 'proguard.cfg' file
 	-libraryjars <user.home>...


- 'ant.properties' file
	- sdk.dir
	- key.store
	
- 'local.properties' file
	- sdk.dir

- 'release.sh' file
	- REPODIR
	- DESTDIR
	
	
---------------------------------
Debugging (in ecplipse)
---------------------------------

Copy folder www from external project into folder assets.
Remember: Folder www under assets will not be the one that is included into apk file when you release through 
ant or release.sh script.