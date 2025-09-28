require 'pagy/extras/metadata'
require 'pagy'
require "pagy/extras/navs"


Pagy::DEFAULT[:items] = 10
Pagy::DEFAULT[:max_items] = 100

# Map per_page param to items
Pagy::DEFAULT[:items_param] = :per_page