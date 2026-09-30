-- Chart templates, Chart.yaml and values.yaml all navigate the same way, and
-- gd/grr are free in a chart: no configured server lists the helm filetype,
-- and yaml-language-server is not enabled for these buffers.
require("user.helm-nav").attach({ goto_keys = true })
