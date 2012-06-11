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
--| Filename         : $Source: /home/byhoe/dev/ada/othello/othello_pkg-callbacks.adb,v $
--| Author           : Adrian Hoe (byhoe)
--| Created On       : 2001/11/15
--| Last Modified By : $Author: byhoe $
--| Last Modified On : $Date: 2001/12/13 09:17:59 $
--| Status           : $State: Exp $
--|
--------------------------------------------------------------------------------
with System; use System;
with Glib; use Glib;
with Gdk.Event; use Gdk.Event;
with Gdk.Types; use Gdk.Types;
with Gtk.Accel_Group; use Gtk.Accel_Group;
with Gtk.Object; use Gtk.Object;
with Gtk.Enums; use Gtk.Enums;
with Gtk.Style; use Gtk.Style;
with Gtk.Widget; use Gtk.Widget;
with Gtk.Main; use Gtk.Main;

package body Othello_Pkg.Callbacks is

   use Gtk.Arguments;

   procedure Shut_Down is
   begin
      Gtk_Exit (0);
   end Shut_Down;

   -----------------------
   -- On_File1_Activate --
   -----------------------

   procedure On_File1_Activate
     (Object : access Gtk_Menu_Item_Record'Class)
   is
   begin
      null;
   end On_File1_Activate;

   ---------------------------
   -- On_New_Game1_Activate --
   ---------------------------

   procedure On_New_Game1_Activate
     (Object : access Gtk_Menu_Item_Record'Class)
   is
   begin
      New_Game (Othello);
   end On_New_Game1_Activate;

   -----------------------
   -- On_Pass1_Activate --
   -----------------------

   procedure On_Pass1_Activate
     (Object : access Gtk_Menu_Item_Record'Class)
   is
   begin
      Pass;
   end On_Pass1_Activate;

   -----------------------
   -- On_Exit1_Activate --
   -----------------------

   procedure On_Exit1_Activate
     (Object : access Gtk_Menu_Item_Record'Class)
   is
   begin
      Shut_Down;
   end On_Exit1_Activate;

   -----------------------
   -- On_Help1_Activate --
   -----------------------

   procedure On_Help1_Activate
     (Object : access Gtk_Menu_Item_Record'Class)
   is
   begin
      null;
   end On_Help1_Activate;

   ------------------------
   -- On_About1_Activate --
   ------------------------

   procedure On_About1_Activate
     (Object : access Gtk_Menu_Item_Record'Class)
   is
   begin
      null;
   end On_About1_Activate;

   procedure On_Othello_Delete_Event
     (Object : access Gtk_Window_Record'Class;
      Params : Gtk.Arguments.Gtk_Args)
   is
      Arg1 : Gdk_Event := To_Event (Params, 1);
   begin
      Shut_Down;
   end On_Othello_Delete_Event;

   ----------------------------------------------
   -- On_Othello_Destroy_Event --
   ----------------------------------------------

   procedure On_Othello_Destroy_Event
     (Object : access Gtk_Window_Record'Class;
      Params : Gtk.Arguments.Gtk_Args)
   is
      Arg1 : Gdk_Event := To_Event (Params, 1);
   begin
      Shut_Down;
   end On_Othello_Destroy_Event;

   -------------------
   -- Gtk_Main_Quit --
   -------------------

   procedure Gtk_Main_Quit
     (Object : access Gtk_Button_Record'Class)
   is
   begin
      Shut_Down;
   end Gtk_Main_Quit;

end Othello_Pkg.Callbacks;
