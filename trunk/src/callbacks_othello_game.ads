--------------------------------------------------------------------------------
--|   Othello - The Classic Othello Game written in Ada
--|
--|   Copyright (C) 2001 Adrian Hoe (byhoe@users.sourceforge.net)
--|
--| Othello is free software; you can redistribute it and/or modify
--| it under the terms of the GNU General Public License as published
--| by the Free Software Foundation; either version 2 of the License,
--| or (at your option) any later version.
--|
--| This software is distributed in the hope that it will be useful,
--| and entertaining but WITHOUT ANY WARRANTY; without even the
--| implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
--| PURPOSE.  See the GNU General Public License for more details.
--|
--| You should have received a copy of the GNU General Public
--| License along with this software; if not, write to the
--| Free Software Foundation, Inc., 59 Temple Place - Suite 330,
--| Boston, MA 02111-1307, USA.
--|
--| Filename         : $Source: /home/byhoe/dev/ada/othello/callbacks_othello_game.ads,v $
--| Author           : Adrian Hoe (byhoe)
--| Created On       : 2001/11/15
--| Last Modified By : $Author: byhoe $
--| Last Modified On : $Date: 2001/12/13 09:18:15 $
--| Status           : $State: Exp $
--|
--------------------------------------------------------------------------------
with Gtk.Handlers;
with Gtk.Window;     use Gtk.Window;
with Gtk.Menu_Item;  use Gtk.Menu_Item;

package Callbacks_Othello_Game is

   package Window_Callback is new Gtk.Handlers.Callback (Gtk_Window_Record);

   package Menu_Item_Callback is new Gtk.Handlers.Callback (Gtk_Menu_Item_Record);

end Callbacks_Othello_Game;
