CFLAGS   =

TARGET   = othello

POSIXBINDING  =/usr/local/lib

GTKADA   = `gtkada-config`

LIBS     = 

SOURCE   = othello_game.adb

VERS     = 1.0.1

$(TARGET): $(SOURCE)
	gnatmake  -o $(TARGET) -O2 $(SOURCE) $(GTKADA)

package:
	tar cvf othello-$(VERS).tar *.adb *.ads Makefile 
	gzip othello-$(VERS).tar
clean:
	rm -f *.ali *.o $(TARGET)
