// ###################################
// #      SlowFetch Installer        #
// ###################################
#include <ncurses.h>
#include <stdlib.h>
#include <string.h>

#define MAX_OPTIONS 2

// Function to print text at a given row and column
void print_at(int row, int col, const char *text) {
    mvprintw(row, col, "%s", text);
}

// Function to display the menu and handle navigation
void menu(const char *options[], int num_options) {
    int ch;
    int highlight = 0;
    int width = COLS;

    while (1) {
        clear();

        // Header with # - # format
        print_at(1, 0, "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#");
        print_at(2, 0, "#              -- [ SlowFetch Installer ] --                #");
        print_at(3, 0, "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#");

        print_at(5, 0, "Would you like to remove README.md?");

        for (int i = 0; i < num_options; ++i) {
            int option_x = 30 + i * 15;  // Spacing out options
            if (i == highlight) {
                attron(A_REVERSE);  // Highlight the selected option
            }
            print_at(7, option_x, options[i]);  // Print options
            attroff(A_REVERSE);
        }

        refresh();
        ch = getch();

        switch (ch) {
            case KEY_LEFT:
                highlight = (highlight == 0) ? num_options - 1 : highlight - 1;
                break;
            case KEY_RIGHT:
                highlight = (highlight == num_options - 1) ? 0 : highlight + 1;
                break;
            case 10:  // Enter key
                if (highlight == 0) {
                    // User selected 'Yes'
                    system("rm README.md");
                    print_at(9, 0, "README.md removed. Press enter");
                    refresh();
                    getch();  // Wait for user input
                    return;
                } else if (highlight == 1) {
                    // User selected 'No'
                    print_at(9, 0, "README.md not removed. Press enter");
                    refresh();
                    getch();  // Wait for user input
                    return;
                }
                break;
            default:
                break;
        }
    }
}

// Function to run 'make'
void run_make() {
    print_at(11, 0, "Running 'make'...");
    refresh();
    system("make");
}

int main() {
    initscr();              // Initialize ncurses
    noecho();               // Don't echo user input
    cbreak();               // Disable line buffering
    keypad(stdscr, TRUE);   // Enable special keys handling

    const char *options[MAX_OPTIONS] = { "[  Yes  ]", "[  No  ]" };
    menu(options, MAX_OPTIONS);  // Display the menu for removing README.md
    run_make();             // Run the 'make' command

    print_at(LINES - 2, 0, "Press any key to exit.");
    refresh();
    getch();                // Wait for user input before exiting

    endwin();               // End ncurses mode
    return 0;
}

