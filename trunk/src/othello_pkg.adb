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
--| Filename         : $Source: /home/byhoe/dev/ada/othello/othello_pkg.adb,v $
--| Author           : Adrian Hoe (byhoe)
--| Created On       : 2001/11/15
--| Last Modified By : $Author: byhoe $
--| Last Modified On : $Date: 2001/12/13 09:17:30 $
--| Status           : $State: Exp $
--|
--------------------------------------------------------------------------------
with Ada.Characters.Latin_1;
with Ada.Unchecked_Conversion;
with Ada.Numerics.Discrete_Random;
with Ada.Text_Io;            use Ada.Text_Io;
with Ada.Integer_Text_Io;    use Ada.Integer_Text_Io;

with Glib;                   use Glib;
with Gtk;                    use Gtk;
with Gdk.Bitmap;             use Gdk.Bitmap;
with Gdk.Cursor;             use Gdk.Cursor;
with Gdk.Pixmap;             use Gdk.Pixmap;
with Gdk.Types;              use Gdk.Types;
with Gdk.Window;             use Gdk.Window;
with Gtk.Widget;             use Gtk.Widget;
with Gtk.Enums;              use Gtk.Enums;
with Gtkada.Handlers;        use Gtkada.Handlers;
with Gtk.Label;              use Gtk.Label;
with Gtk.Pixmap;             use Gtk.Pixmap;
with Gtk.Style;              use Gtk.Style;
with Gtk.Button;             use Gtk.Button;
with Gtk.Handlers;           use Gtk.Handlers;
with Gtk.Arguments;          use Gtk.Arguments;

with Callbacks_Othello_Game; use Callbacks_Othello_Game;
with Othello_Pkg.Callbacks;  use Othello_Pkg.Callbacks;

with Board_Pkg;              use Board_Pkg;

package body Othello_Pkg is
   ----------------------------------------------------------------------------
   package Button_Callback is new Gtk.Handlers.Callback (Gtk_Button_Record);

   Button_Size  : constant := 50;
   Hand_Cursor  : constant Gint := 60;
   Left_Pointer : constant Gint := 68;

   use type Board_Pkg.Cell_Status;
   type Board_Matrix is array (Board_Pkg.Valid_Row, Board_Pkg.Valid_Column) of Board_Pkg.Cell_Record;
   Playing_Board : Board_Matrix;

   subtype Bead_Color is Board_Pkg.Cell_Status;

   Whose_Move    : Bead_Color := Blue;
   Player_Move   : Bead_Color := Blue;
   Computer_Move : Bead_Color := Red;

   type Possible_Moves_Record is
      record
         Row    : Board_Pkg.Valid_Row;
         Column : Board_Pkg.Valid_Column;
         Check  : Integer;
         Side   : Integer;
      end record;
   type Possible_Moves_Matrix is array (Positive range <>) of Possible_Moves_Record;

   -----------------------
   --   Unsigned Byte   --
   -----------------------
   type Othello_Integer is mod 256;

   ----------------------------------------------------------------------------
   procedure Beep
   is
      Bell : constant Character := Ada.Characters.Latin_1.Bel;
   begin
      Ada.Text_Io.Put (Bell);
   end Beep;
   ----------------------------------------------------------------------------
   function Image (Row    : in Board_Pkg.Valid_Row;
                   Column : in Board_Pkg.Valid_Column)
                  return String
   is
   --Returns a 4-Character String of the form "RRCC", where
   --    RR is the zero-filled image of Row
   --    CC is the zero-filled image of Column
      Row_Image    : String   := Board_Pkg.Valid_Row'Image    (Row);
      Column_Image : String   := Board_Pkg.Valid_Column'Image (Column);
      Row_First    : Positive := Row_Image'First;
      Column_First : Positive := Column_Image'First;
   begin -- Image
      Row_Image (Row_Image'First) := '0';
      Column_Image (Column_Image'First) := '0';

      return Row_Image (Row_First .. Row_Image'Last) & "-" & Column_Image (Column_First .. Column_Image'Last);
   end Image;
   ----------------------------------------------------------------------------
   procedure Put_Bead (Location : in out Board_Pkg.Cell_Record)
   is
      Style     : Gtk_Style;
      Pixmap    : Gdk_Pixmap;
      Mask      : Gdk_Bitmap;
      PixmapWid : Gtk_Pixmap;
   begin
      Style := Get_Style (Location.Button);
      if Location.Cell = Blue then
         Create_From_Xpm
           (Pixmap,
            Get_Window (Location.Button),
            Mask,
            Get_Bg (Style, State_Normal),
            "blue_bead.xpm");
      else
         Create_From_Xpm
           (Pixmap,
            Get_Window (Location.Button),
            Mask,
            Get_Bg (Style, State_Normal),
            "red_bead.xpm");
      end if;
      Gtk_New (PixmapWid, Pixmap, Mask);
      Location.Pixmap := PixmapWid;
      Add (Location.Button, PixmapWid);
      Show_All (Location.Button);
   end Put_Bead;
   ----------------------------------------------------------------------------
   procedure Remove_Bead (Location : in out Board_Pkg.Cell_Record)
   is
   begin
      Remove (Location.Button, Location.Pixmap);
   end Remove_Bead;
   ----------------------------------------------------------------------------
   procedure Flip_Bead (Location : in out Cell_Record)
   is
   begin
      Remove_Bead (Location);
      Put_Bead (Location);
   end Flip_Bead;
   ----------------------------------------------------------------------------
   function Check_Move_1 (This_Board : in Board_Matrix;
                          Row        : in Board_Pkg.Valid_Row;
                          Column     : in Board_Pkg.Valid_Column;
                          Dx         : in Integer;
                          Dy         : in Integer;
                          Player     : in Bead_Color)
                         return Integer
   is
      DRow    : Integer := Integer (Row);
      DColumn : Integer := Integer (Column);
      Factor  : Integer := 0;
   begin -- Check_Move_1
      loop
         DRow    := DRow    + Dy;
         DColumn := DColumn + Dx;
         exit when not (DColumn in Board_Pkg.Valid_Column and DRow in Board_Pkg.Valid_Row);
         if This_Board (Board_Pkg.Valid_Row (DRow), Board_Pkg.Valid_Column (DColumn)).Cell = Empty then
            return 0;
         elsif This_Board (Board_Pkg.Valid_Row (DRow), Board_Pkg.Valid_Column(DColumn)).Cell = Player then
            return Factor;
         elsif (DColumn = 1 or DColumn = 8 or DRow = 1 or DRow = 8) then
            Factor := Factor + 10;
         else
            Factor := Factor + 1;
         end if;
      end loop;
      return 0;
   end Check_Move_1;
   ----------------------------------------------------------------------------
   function Check_Move (This_Board : in Board_Matrix;
                        Row        : in Board_Pkg.Valid_Row;
                        Column     : in Board_Pkg.Valid_Column;
                        Player     : in Bead_color)
                       return Integer
   is
   begin -- Check_Move
      if This_Board (Row, Column).Cell /= Empty then
         return 0;
      else
         return (Check_Move_1 (This_Board, Row, Column,  0,  1, Player) +
                 Check_Move_1 (This_Board, Row, Column,  1,  0, Player) +
                 Check_Move_1 (This_Board, Row, Column,  0, -1, Player) +
                 Check_Move_1 (This_Board, Row, Column, -1,  0, Player) +
                 Check_Move_1 (This_Board, Row, Column,  1,  1, Player) +
                 Check_Move_1 (This_Board, Row, Column,  1, -1, Player) +
                 Check_Move_1 (This_Board, Row, Column, -1,  1, Player) +
                 Check_Move_1 (This_Board, Row, Column, -1, -1, Player));
      end if;
   end Check_Move;
   ----------------------------------------------------------------------------
   function Count_Bead (Color : in Bead_Color)
                       return integer
   is
      Count : Integer := 0;
   begin
      for Row in Board_Pkg.Valid_Row loop
         for Column in Board_Pkg.Valid_Column loop
            if Playing_Board (Row, Column).Cell = Color then
               Count := Count + 1;
            end if;
         end loop;
      end loop;
      return Count;
   end Count_Bead;
   ----------------------------------------------------------------------------
   procedure Update (Statusbar : in Gtk_Statusbar;
                     Message   : in     String)
   is
      Id : Message_Id;
   begin
      Pop (Statusbar, 1);
      Id := Push (Statusbar, 1, Message);
   end Update;
   ----------------------------------------------------------------------------
   procedure Update_Count
   is
      S          : String (1 .. 2);
   begin
      Put (S, Count_Bead (Blue));
      Update (Othello.Blue_Statusbar, "Blue = " & S);

      Put (S, Count_Bead (Red));
      Update (Othello.Red_Statusbar, "Red = " & S);
   end Update_Count;
   ----------------------------------------------------------------------------
   procedure Put_Move_1 (This_Board : in out Board_Matrix;
                         Row        : in     Board_Pkg.Valid_Row;
                         Column     : in     Board_Pkg.Valid_Column;
                         Dx         : in     Integer;
                         Dy         : in     Integer;
                         Player     : in     Bead_Color)
   is
      DRow    : Integer := Integer (Row);
      DColumn : Integer := Integer (Column);
   begin
      loop
         DRow    := DRow    + Dy;
         DColumn := DColumn + Dx;
         exit when not (DColumn in Board_Pkg.Valid_Column and DRow in Board_Pkg.Valid_Row);
         if This_Board (DRow, DColumn).Cell = Empty or This_Board (DRow, DColumn).Cell = Player then
            exit;
         end if;
         This_Board (DRow, DColumn).Cell := Player;

         if This_Board (DRow, DColumn).Flag then
            Flip_Bead (This_Board (DRow, DColumn));
         end if;
      end loop;
   end Put_Move_1;
   ----------------------------------------------------------------------------
   procedure Put_Move (This_Board : in out Board_Matrix;
                       Row        : in     Board_Pkg.Valid_Row;
                       Column     : in     Board_Pkg.Valid_Column;
                       Player     : in     Bead_Color)
   is
   begin
      This_Board (Row, Column).Cell := Player;

      if This_Board (Row, Column).Flag then
         Put_Bead (This_Board (Row, Column));
      end if;

      for Dx in -1 .. 1 loop
         for Dy in -1 .. 1 loop
            if (Dx /= 0 or Dy /= 0) and Check_Move_1 (This_Board, Row, Column, Dx, Dy, Player) > 0 then
               Put_Move_1 (This_Board, Row, Column, Dx, Dy, Player);
            end if;
         end loop;
      end loop;
      Update_Count;
   end Put_Move;
   ----------------------------------------------------------------------------
   procedure Copy_Board (Target_Board :    out Board_Matrix;
                         Source_Board : in     Board_Matrix;
                         Flag         : in     Boolean := True)
   is
   begin
      for I in Board_Pkg.Valid_Row loop
         for J in Board_Pkg.Valid_Column loop
            Target_Board (I, J) := Source_Board (I, J);
            Target_Board (I, J).Flag := Flag;
         end loop;
      end loop;
   end Copy_Board;
   ----------------------------------------------------------------------------
   function No_Take (This_Board : in Board_Matrix;
                     Row        : in Board_Pkg.Valid_Row;
                     Column     : in Board_Pkg.Valid_Column)
                    return Boolean
   is

      function No_Take_1 (This_Board : in Board_Matrix;
                          Row        : in Board_Pkg.Valid_Row;
                          Column     : in Board_Pkg.Valid_Column;
                          Dx         : in Integer;
                          Dy         : in Integer)
                         return Boolean
      is
         ----------------------------------------------------------------------
         function No_Take_2 (This_Board : in Board_Matrix;
                             Row        : in Board_Pkg.Valid_Row;
                             Column     : in Board_Pkg.Valid_Column;
                             Dx         : in Integer;
                             Dy         : in Integer)
                            return Board_Pkg.Cell_Status
         is
            DRow    : Integer := Row;
            DColumn : integer := Column;
         begin -- No_Take_2
            DRow    := DRow    + Dy;
            DColumn := DColumn + Dx;
            if DRow in Board_Pkg.Valid_Row and DColumn in Board_Pkg.Valid_Column then
               while This_Board (DRow, DColumn).Cell = Empty loop
                  DRow    := DRow    + Dy;
                  DColumn := DColumn + Dx;
                  if (DRow < 1 or DRow > 8 or DColumn < 1 or DColumn > 8) or else
                    This_Board (DRow, DColumn).Cell = Empty then
                     return Player_Move;
                  end if;
               end loop;
            end if;
            while (DRow >= 1 and DRow <= 8 and DColumn >= 1 and DColumn <= 8) and then
              This_Board (DRow, DColumn).Cell = Computer_Move loop
               DRow    := DRow    + Dy;
               DColumn := DColumn + Dx;
            end loop;
            if DRow < 1 or DRow > 8 or DColumn < 1 or DColumn > 8 then
               return Computer_Move;
            end if;
            return This_Board (DRow, DColumn).Cell;
         end No_Take_2;
         ----------------------------------------------------------------------
         C1, C2 : Board_Pkg.Cell_Status;

      begin -- No_Take_1
         C1 := No_Take_2 (This_Board, Row, Column,  Dx,  Dy);
         C2 := No_Take_2 (This_Board, Row, Column, -Dx, -Dy);
         return not ((C1 = Player_Move and C2 = Empty) or
                     (C1 = Empty and C2 = Player_Move));
      end No_Take_1;

   begin -- No_Take
      return (No_Take_1 (This_Board, Row, Column, 0,  1) and
              No_Take_1 (This_Board, Row, Column, 1,  1) and
              No_Take_1 (This_Board, Row, Column, 1,  0) and
              No_Take_1 (This_Board, Row, Column, 1, -1));
   end No_Take;
   ----------------------------------------------------------------------------
   function Side_Move (Row      : in Board_Pkg.Valid_Row;
                       Column   : in Board_Pkg.Valid_Column;
                       Computer : in Bead_Color)
                      return Integer
   is
      Dummy_Board : Board_Matrix;
      Ok, Dkl     : Integer;
      C, S        : Integer;
      Side        : Integer := 0;
      Oside       : Othello_Integer;
   begin
      Copy_Board (Dummy_Board, Playing_Board, False);
      Put_Move (Dummy_Board, Row, Column, Computer);

      if Row = Board_Pkg.Valid_Row'First or Row = Board_Pkg.Valid_Row'Last then
         Side := Side + 1;
      end if;

      if Column = Board_Pkg.Valid_Column'First or Column = Board_Pkg.Valid_Column'Last then
         Side := Side + 1;
      end if;

      S  := 0;
      Ok := 0;

      if Side = 2 or No_Take (Playing_Board, Row, Column) then
         Ok := Ok + 1;
      end if;

      Oside := 0;
      for K in Board_Pkg.Valid_Row loop
         for L in Board_Pkg.Valid_Column loop
            C := Check_Move (Dummy_Board, K, L, Computer);
            if C > 0 then
               Dkl := 1;
               if K = Board_Pkg.Valid_Row'First or K = Board_Pkg.Valid_Row'Last then
                  Dkl   := Dkl + 2;
                  Oside := Oside or 4;
               end if;
               if L = Board_Pkg.Valid_Column'First or L = Board_Pkg.Valid_Column'Last then
                  Dkl   := Dkl + 2;
                  Oside := Oside or 4;
               end if;
               if Dkl = 5 then
                  Dkl   := 10;
                  Oside := Oside or 16;
                  Oside := Oside or 1;
                  S     := S - Dkl;
                  if C >= 10 then
                     S     := S - 4;
                     Oside := Oside or 8;
                  end if;
               elsif No_Take (Dummy_Board, K, L) then
                  Oside := Oside or Othello_Integer (1);
                  S     := S - Dkl;
                  if C >= 10 then
                     S     := S - 4;
                     Oside := Oside or 8;
                  end if;
               end if;
            end if;
         end loop;
      end loop;

      if S < Integer (-Oside) then
         S := Integer (-Oside);
      end if;

      if Side > 0 then
         return (S + Side - 7 + 10 * Ok);
      end if;

      if (Row = Board_Pkg.Valid_Row'First + 1) or (Row = Board_Pkg.Valid_Row'Last - 1) then
         S    := S - 1;
         Side := Side + 1;
      end if;

      if (Column = Board_Pkg.Valid_Column'First  + 1) or (Column = Board_Pkg.Valid_Column'Last - 1) then
         S    := S - 1;
         Side := Side + 1;
      end if;

      if Side > 0 then
         return S;
      end if;

      if (Row = Board_Pkg.Valid_Row'First + 2) or (Row = Board_Pkg.Valid_Row'Last - 2) then
         S    := S + 1;
      end if;

      if (Column = Board_Pkg.Valid_Column'First  + 2) or (Column = Board_Pkg.Valid_Column'Last - 2) then
         S    := S + 1;
      end if;

      return S;
   end Side_Move;
   ----------------------------------------------------------------------------
   procedure Get_Possible_Moves (Computer       : in     Bead_Color;
                                 Possible_Moves :    out Possible_Moves_Matrix;
                                 Factor         :    out Integer)
   is
      K : Integer := 1;
   begin
      Factor := 0;
      for I in Board_Pkg.Valid_Row loop
         for J in Board_Pkg.Valid_Column loop
            Possible_Moves (K).Check := Check_Move (Playing_Board, I, J, Computer);
            if Possible_Moves (K).Check > 0 then
               Possible_Moves (K).Row    := I;
               Possible_Moves (K).Column := J;
               Possible_Moves (K).Side   := Side_Move (I, J, Computer);
               Factor := Factor + 1;
               K      := K + 1;
            end if;
         end loop;
      end loop;
   end Get_Possible_Moves;
   ----------------------------------------------------------------------------
   procedure Pick_Move (Possible_Moves : in     Possible_Moves_Matrix;
                        Factor         : in     Integer;
                        Row            :    out Board_Pkg.Valid_Row;
                        Column         :    out Board_Pkg.Valid_Column)
   is
      subtype Move is Integer range 1 .. Factor;

      package Random_Move is new Ada.Numerics.Discrete_Random (Move);
      use Random_Move;

      G        : Generator;
      The_Move : Move;
   begin
      Reset (G);

      The_Move := Random (G);

      Row      := Possible_Moves (The_Move).Row;
      Column   := Possible_Moves (The_Move).Column;

   end Pick_Move;
   ----------------------------------------------------------------------------
   procedure Computer_Make_Move
   is
      Row             : Board_Pkg.Valid_Row;
      Column          : Board_Pkg.Valid_Column;
      Possible_Moves  : Possible_Moves_Matrix (1 .. 64);
      Computer_Factor : Integer;
      Player_Factor   : Integer;
   begin
      Update (Othello.Main_Statusbar, "Computer move");
      Get_Possible_Moves (Computer_Move, Possible_Moves, Computer_Factor);
      if Computer_Factor > 0 then
         Pick_Move (Possible_Moves, Computer_Factor, Row, Column);
         Put_Move (Playing_Board, Row, Column, Computer_Move);
      end if;
      Get_Possible_Moves (Player_Move, Possible_Moves, Player_Factor);
      if Player_Factor > 0 then
         Whose_Move := Player_Move;
         Update (Othello.Main_Statusbar, "Your move");
      else
         Get_Possible_Moves (Computer_Move, Possible_Moves, Computer_Factor);
         if Computer_Factor > 0 then
            Update (Othello.Main_Statusbar, "You must pass!");
         else
            declare
               Blue_Count : Integer := Count_Bead (Blue);
               Red_Count  : Integer := Count_Bead (Red);
            begin
               if Blue_Count = Red_Count then
                  Update (Othello.Main_Statusbar, "Tie");
               elsif Blue_Count > Red_Count then
                  Update (Othello.Main_Statusbar, "You win!");
               else
                  Update (Othello.Main_Statusbar, "You lose!");
               end if;
            end ;
         end if;
      end if;
   end Computer_Make_Move;
   ----------------------------------------------------------------------------
   procedure Pass
   is
   begin
      Computer_Make_Move;
   end Pass;
   ----------------------------------------------------------------------------
   procedure Set_Cursor (Cursor_Type : in Gint)
   is
      pragma Warnings (Off);
      function To_Cursor is new Ada.Unchecked_Conversion (Gint, Gdk_Cursor_Type);
      pragma Warnings (On);

      C           : Gint;
      This_Window : Gdk_Window := Get_Window (Othello.Table1);
      Cursor      : Gdk_Cursor := Null_Cursor;
   begin
      C := Cursor_Type mod 154;
      Gdk_New (Cursor, To_Cursor (C));
      Set_Cursor (This_Window, Cursor);
      Destroy (Cursor);
   end Set_Cursor;
   ----------------------------------------------------------------------------
   procedure Make_Move (Object : access Gtk_Button_Record'Class;
                        Param  : Gtk_Args)
   is
      Name   : constant String := Get_Name (Object);
      Row    : constant Board_Pkg.Valid_Row    := Board_Pkg.Valid_Row'Value    (Name (Name'First    .. Name'First + 1));
      Column : constant Board_Pkg.Valid_Column := Board_Pkg.Valid_Column'Value (Name (Name'Last - 1 .. Name'Last));
   begin
      if Playing_Board (Row, Column).Cell /= Empty then
         Beep;
      else
         if Whose_Move = Computer_Move then
            Beep;
         else
            if Check_Move (Playing_Board, Row, Column, Player_Move) > 0 then
               Put_Move (Playing_Board, Row, Column, Player_Move);
               Set_Cursor (Left_Pointer);
               Whose_Move := Computer_Move;
               Computer_Make_Move;
            else
               Beep;
            end if;
         end if;
      end if;
   end Make_Move;
   ----------------------------------------------------------------------------
   procedure Hide_Clue (Object : access Gtk_Button_Record'Class)
   is
   begin
      Set_Cursor (Left_Pointer);
   end Hide_Clue;
   ----------------------------------------------------------------------------
   procedure Show_Clue (Object : access Gtk_Button_Record'Class)
   is
      Name   : constant String := Get_Name (Object);
      Row    : constant Board_Pkg.Valid_Row    := Board_Pkg.Valid_Row'Value    (Name (Name'First    .. Name'First + 1));
      Column : constant Board_Pkg.Valid_Column := Board_Pkg.Valid_Column'Value (Name (Name'Last - 1 .. Name'Last));
   begin
      if Playing_Board (Row, Column).Cell = Empty and
        Check_Move (Playing_Board, Row, Column, Player_Move) > 0 then
         Set_Cursor (Hand_Cursor);
      end if;
   end Show_Clue;
   ----------------------------------------------------------------------------
   procedure Setup_Board (Othello : access Othello_Record'Class)
   is
   begin
      for Row in Board_Pkg.Valid_Row loop
         for Column in Board_Pkg.Valid_Column loop
            if Playing_Board (Row, Column).Cell /= Empty then
               Remove_Bead (Playing_Board (Row, Column));
               Playing_Board (Row, Column).Cell := Empty;
            end if;
            if not Playing_Board (Row, Column).Button_Setup then
               Gtk_New (Playing_Board (Row, Column).Button);
               Set_Name (Playing_Board (Row, Column).Button, Image (Row, Column));
               Set_USize (Playing_Board (Row, Column).Button, Button_Size, Button_Size);
               Button_Callback.Connect
                 (Playing_Board (Row, Column).Button,
                  "clicked",
                  Make_Move'Access);
               Button_Callback.Connect
                 (Playing_Board (Row, Column).Button,
                  "enter",
                  Button_Callback.To_Marshaller (Show_Clue'Access));
               Button_Callback.Connect
                 (Playing_Board (Row, Column).Button,
                  "leave",
                  Button_Callback.To_Marshaller (Hide_Clue'Access));
               Attach (Othello.Table1,
                       Playing_Board (Row, Column).Button,
                       Glib.Guint (Column) - 1,
                       Glib.Guint (Column),
                       Glib.Guint (Row) - 1,
                       Glib.Guint (Row) );
               Playing_Board (Row, Column).Button_Setup := True;
            end if;
            Playing_Board (Row, Column).Flag := True;
         end loop;
      end loop;
      Show_All (Othello);

      Playing_Board (4, 4).Cell := Red;
      Put_Bead (Playing_Board (4, 4));

      Playing_Board (5, 5).Cell := Red;
      Put_Bead (Playing_Board (5, 5));

      Playing_Board (4, 5).Cell := Blue;
      Put_Bead (Playing_Board (4, 5));

      Playing_Board (5, 4).Cell := Blue;
      Put_Bead (Playing_Board (5, 4));
   end Setup_Board;
   ----------------------------------------------------------------------------
   procedure New_Game (Othello : access Othello_Record'Class)
   is
   begin
      Whose_Move := Player_Move;
      Setup_Board (Othello);
   end New_Game;
   ----------------------------------------------------------------------------
   procedure Gtk_New (Othello : out Othello_Access) is
   begin
      Othello := new Othello_Record;
      Othello_Pkg.Initialize (Othello);
   end Gtk_New;
   ----------------------------------------------------------------------------
   procedure Initialize (Othello : access Othello_Record'Class) is
      pragma Suppress (All_Checks);
   begin
      Gtk.Window.Initialize (Othello, Window_Toplevel);
      Set_Title (Othello, "AdaOthello");
      Set_Policy (Othello, False, False, False);
      Set_Position (Othello, Win_Pos_None);
      Set_Modal (Othello, False);
      Set_Default_Size (Othello, 400, 400);

      Gtk_New_Vbox (Othello.Vbox1, False, 0);
      Add (Othello, Othello.Vbox1);

      Gtk_New (Othello.Menubar1);
      Set_Shadow_Type (Othello.Menubar1, Shadow_Out);
      Set_USize (Othello.Menubar1, 35, 24);
      Pack_Start (Othello.Vbox1, Othello.Menubar1, False, False, 0);

      Gtk_New (Othello.File1, "File");
      Set_Right_Justify (Othello.File1, False);
      Menu_Item_Callback.Connect
        (Othello.File1, "activate",
         Menu_Item_Callback.To_Marshaller (On_File1_Activate'Access));
      Add (Othello.Menubar1, Othello.File1);

      Gtk_New (Othello.File1_Menu);
      Set_Submenu (Othello.File1, Othello.File1_Menu);

      Gtk_New (Othello.New_Game1, "New Game");
      Set_Right_Justify (Othello.New_Game1, False);
      Menu_Item_Callback.Connect
        (Othello.New_Game1, "activate",
         Menu_Item_Callback.To_Marshaller (On_New_Game1_Activate'Access));
      Add (Othello.File1_Menu, Othello.New_Game1);

      Gtk_New (Othello.Pass1, "Pass");
      Set_Right_Justify (Othello.Pass1, False);
      Menu_Item_Callback.Connect
        (Othello.Pass1, "activate",
         Menu_Item_Callback.To_Marshaller (On_Pass1_Activate'Access));
      Add (Othello.File1_Menu, Othello.Pass1);

      Gtk_New (Othello.Exit1, "Exit");
      Set_Right_Justify (Othello.Exit1, False);
      Menu_Item_Callback.Connect
        (Othello.Exit1, "activate",
         Menu_Item_Callback.To_Marshaller (On_Exit1_Activate'Access));
      Add (Othello.File1_Menu, Othello.Exit1);

      Gtk_New (Othello.Help1, "Help");
      Set_Right_Justify (Othello.Help1, True);
      Menu_Item_Callback.Connect
        (Othello.Help1, "activate",
         Menu_Item_Callback.To_Marshaller (On_Help1_Activate'Access));
      Add (Othello.Menubar1, Othello.Help1);

      Gtk_New (Othello.Help1_Menu);
      Set_Submenu (Othello.Help1, Othello.Help1_Menu);

      Gtk_New (Othello.About1, "About");
      Set_Right_Justify (Othello.About1, False);
      Menu_Item_Callback.Connect
        (Othello.About1, "activate",
         Menu_Item_Callback.To_Marshaller (On_About1_Activate'Access));
      Add (Othello.Help1_Menu, Othello.About1);

      Window_Callback.Connect
        (Othello, "delete_event", On_Othello_Delete_Event'Access);
      Window_Callback.Connect
        (Othello, "destroy_event", On_Othello_Destroy_Event'Access);

      Gtk_New (Othello.Table1, 8, 8, True);
      Set_Row_Spacings (Othello.Table1, 0);
      Set_Col_Spacings (Othello.Table1, 0);
      Pack_Start (Othello.Vbox1, Othello.Table1, True, True, 0);

      Gtk_New_Hbox (Othello.Hbox1, False, 0);
      Pack_Start (Othello.Vbox1, Othello.Hbox1, False, False, 0);

      Gtk_New (Othello.Main_Statusbar);
      Set_USize (Othello.Main_Statusbar, 160, 20);
      Pack_Start (Othello.Hbox1, Othello.Main_Statusbar, False, False, 0);

      Gtk_New (Othello.Blue_Statusbar);
      Set_USize (Othello.Blue_Statusbar, 120, 20);
      Pack_Start (Othello.Hbox1, Othello.Blue_Statusbar, False, False, 0);

      Gtk_New (Othello.Red_Statusbar);
      Set_USize (Othello.Red_Statusbar, 120, 20);
      Pack_Start (Othello.Hbox1, Othello.Red_Statusbar, False, False, 0);

      New_Game (Othello);

   end Initialize;
   ----------------------------------------------------------------------------
end Othello_Pkg;
