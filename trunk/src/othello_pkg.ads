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
--| Filename         : $Source: /home/byhoe/dev/ada/othello/othello_pkg.ads,v $
--| Author           : Adrian Hoe (byhoe)
--| Created On       : 2001/11/15
--| Last Modified By : $Author: byhoe $
--| Last Modified On : $Date: 2001/12/13 09:16:52 $
--| Status           : $State: Exp $
--|
--------------------------------------------------------------------------------
with Gtk.Window;      use Gtk.Window;
with Gtk.Box;         use Gtk.Box;
with Gtk.Menu;        use Gtk.Menu;
with Gtk.Menu_Bar;    use Gtk.Menu_Bar;
with Gtk.Menu_Item;   use Gtk.Menu_Item;
with Gtk.Table;       use Gtk.Table;
with Gtk.Button;      use Gtk.Button;
with Gtk.Status_Bar;  use Gtk.Status_Bar;

package Othello_Pkg is

   type Othello_Record is new Gtk_Window_Record with record
      Vbox1          : Gtk_Vbox;
      Menubar1       : Gtk_Menu_Bar;
      File1          : Gtk_Menu_Item;
      File1_Menu     : Gtk_Menu;
      New_Game1      : Gtk_Menu_Item;
      Pass1          : Gtk_Menu_Item;
      Exit1          : Gtk_Menu_Item;
      Help1          : Gtk_Menu_Item;
      Help1_Menu     : Gtk_Menu;
      About1         : Gtk_Menu_Item;
      Table1         : Gtk_Table;
      Hbox1          : Gtk_Hbox;
      Main_Statusbar : Gtk_Statusbar;
      Blue_Statusbar : Gtk_Statusbar;
      Red_Statusbar  : Gtk_Statusbar;
   end record;
   type Othello_Access is access all Othello_Record'Class;

   procedure Pass;
   procedure New_Game (Othello : access Othello_Record'Class);

   procedure Gtk_New (Othello : out Othello_Access);
   procedure Initialize (Othello : access Othello_Record'Class);

   Othello : Othello_Access;

end Othello_Pkg;
