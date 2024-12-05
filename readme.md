# Jenkins with Configuration as Code plugin with LDAP authentication



# list installed plugins
```
def pluginList = new ArrayList(Jenkins.instance.pluginManager.plugins)
pluginList.sort { it.getShortName() }.each{
  plugin -> 
    println ("${plugin.getShortName()}:${plugin.getVersion()}")
}
```
