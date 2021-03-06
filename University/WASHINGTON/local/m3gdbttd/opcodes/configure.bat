@echo off
echo Configuring opcodes for go32
rem This batch file assumes a unix-type "sed" program

echo # Makefile generated by "configure.bat"> Makefile

if exist config.sed del config.sed

echo "/\.o[ 	]*:/ s/config.status//			">> config.sed
echo "s/CC = cc/CC = gcc/				">> config.sed

echo "/^###$/ i\					">> config.sed
echo "BFD_MACHINES=i386-dis.o				">> config.sed

echo "s/^[ 	]*rm/	-rm/				">> config.sed

sed -e "s/^\"//" -e "s/\"$//" -e "s/[ 	]*$//" config.sed > config2.sed
sed -f config2.sed Makefile.in >> Makefile
del config.sed
del config2.sed
