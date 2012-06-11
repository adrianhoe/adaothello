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
--| Filename         : $Source: /home/byhoe/dev/ada/othello/board_pkg.ads,v $
--| Author           : Adrian Hoe (byhoe)
--| Created On       : 2001/11/15
--| Last Modified By : $Author: byhoe $
--| Last Modified On : $Date: 2001/12/13 09:18:25 $
--| Status           : $State: Exp $
--|
--------------------------------------------------------------------------------
with Gtk.Label;            use Gtk.Label;
with Gtk.Button;           use Gtk.Button;
with Gtk.Pixmap;           use Gtk.Pixmap;
with System;

package Board_Pkg is

   subtype Valid_Row    is Positive range 1 .. 8; -- Size of the mine field
   subtype Valid_Column is Positive range 1 .. 8;

   type Cell_Status is (Empty, Blue, Red);
   type Cell_Record is
      record
         Cell         : Cell_Status := Empty;
         Button       : Gtk_Button;
         Pixmap       : Gtk_Pixmap;
         Flag         : Boolean := True;
         Button_Setup : Boolean := False;
      end record;

end Board_Pkg;
