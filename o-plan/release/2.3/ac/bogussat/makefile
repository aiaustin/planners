CFLAGS = -g
LIBS = -lsuntool -lsunwindow -lpixrect -ll
OBJS = demo.o

demo:	$(OBJS)
	cc $(CFLAGS) -o demo ${OBJS} $(LIBS)

demo.o:	demo.l
