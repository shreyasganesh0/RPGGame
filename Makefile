TARGET = bin/final

SRC = $(wildcard src/*.cpp)

OBJ = $(patsubst src/%.cpp, obj/%.o, $(SRC))



default: $(TARGET)



clean:

	rm -f obj/*.o

	rm -f bin/*



$(TARGET): $(OBJ)

	g++ -o $@ $?



obj/%.o : src/%.cpp

	g++ -c $< -o $@ -Iinclude