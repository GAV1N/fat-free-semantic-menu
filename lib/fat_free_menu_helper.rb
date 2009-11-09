# Use as so:
# <%= semantic_menu do |root|
#   root.add "overview", root_path
#   root.add "comments", comments_path
# end %>
#
# Assuming you are on /comments, the output would be:
#
# <ul class="menu">
#   <li>
#     <a href="/">overview</a>
#   </li>
#   <li class="active">
#     <a href="/comments">comments</a>
#   </li>
# </ul>
module FatFreeMenuHelper

  def fat_free_semantic_menu(opts={})
    menu = FatFreeSemanticMenu.new(controller,opts)
    menu.add_semantic_menu_levels(menu,tabs)
    menu.to_s
  end
  
end
