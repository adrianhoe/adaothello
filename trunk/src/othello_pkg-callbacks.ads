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
--| Filename         : $Source: /home/byhoe/dev/ada/othello/othello_pkg-callbacks.ads,v $
--| Author           : Adrian Hoe (byhoe)
--| Created On       : 2001/11/15
--| Last Modified By : $Author: byhoe $
--| Last Modified On : $Date: 2001/12/13 09:17:44 $
--| Status           : $State: Exp $
--|
--------------------------------------------------------------------------------
with Gtk.Arguments;

package Othello_Pkg.Callbacks is

   procedure On_File1_Activate
     (Object : access Gtk_Menu_Item_Record'Class);

   procedure On_New_Game1_Activate
     (Object : access Gtk_Menu_Item_Record'Class);

   procedure On_Pass1_Activate
     (Object : access Gtk_Menu_Item_Record'Class);

   procedure On_Exit1_Activate
     (Object : access Gtk_Menu_Item_Record'Class);

   procedure On_Help1_Activate
     (Object : access Gtk_Menu_Item_Record'Class);

   procedure On_About1_Activate
     (Object : access Gtk_Menu_Item_Record'Class);

   procedure On_Othello_Delete_Event
     (Object : access Gtk_Window_Record'Class;
      Params : Gtk.Arguments.Gtk_Args);

   procedure On_Othello_Destroy_Event
     (Object : access Gtk_Window_Record'Class;
      Params : Gtk.Arguments.Gtk_Args);

   procedure Gtk_Main_Quit
     (Object : access Gtk_Button_Record'Class);

end Othello_Pkg.Callbacks;
