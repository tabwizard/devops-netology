// this file has the param overrides for the stage environment
local prod = import './stage.libsonnet';

prod {
  components +: {
    mytestapp +: {
      replicas: 3,
    },
    endpoint: {
      address: "87.250.250.242"
    }
  }
}
