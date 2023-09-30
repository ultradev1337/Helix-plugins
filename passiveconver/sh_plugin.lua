local PLUGIN = PLUGIN;
PLUGIN.name = "Passive Voice"
PLUGIN.author = "Ultradev"
PLUGIN.description = "Conversacion pasiva"

ix.config.Add( "Use Passive Voice", true, "Crea una conversacion", nil,
  {
  category = "Combine Improvements"
} )

ix.util.Include("cl_plugin.lua");
ix.util.Include("sv_plugin.lua");
ix.util.Include("sv_hooks.lua");