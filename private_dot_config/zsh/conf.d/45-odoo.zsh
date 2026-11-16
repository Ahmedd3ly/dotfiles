# Odoo dev: shared upstream code in $ODOO_ROOT/versions/<x.0>, one workspace per client in $ODOO_ROOT/clients
typeset -g ODOO_ROOT=~/Projects/odoo

# odoo <client> [odoo-bin args]: run a client with its venv, its config, and the version named in .odoo-version
odoo() {
  local c=$ODOO_ROOT/clients/${1:?usage: odoo <client> [odoo-bin args]}; shift
  [[ -r $c/.odoo-version ]] || { print -u2 "odoo: no .odoo-version in $c"; return 1; }
  local v=$(<$c/.odoo-version)
  systemctl is-active -q postgresql || { print -u2 "odoo: postgresql stopped (sudo systemctl start postgresql)"; return 1; }
  $c/.venv/bin/python $ODOO_ROOT/versions/$v/odoo/odoo-bin -c $c/odoo.conf "$@"
}

# onv <client>: cd into a client workspace and open nvim
onv() { cd $ODOO_ROOT/clients/${1:?usage: onv <client>} && nvim; }
