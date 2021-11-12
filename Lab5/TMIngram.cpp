#include <iostream>
#include <fstream>
#include <iomanip>
#include <string>

using namespace std;

    //Display a welcome message and instructions on how to make a valid withdrawal
    void displayWelcomeMessage()
    {
        cout << "Welcome to the TMIngram program!" << endl;
        cout << "Enter how much you want to withdraw. Note that the amount must be a multiple of 10 under 200" << endl; 
   }

    //Prompt the user for the amount they want to withdraw
    int getWithdrawalAmount()
    {
        int amount;
        cout << "Enter the amount you want to withdraw: ";
        cin >> amount;
        return amount;
    }

    //Check if the amount entered is valid
    bool isValidAmount(int amount, int remainingCash)
    {
        if (amount % 10 == 0 && amount <= 200 && amount <= remainingCash)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    //Determine the number of 20s to be dispensed
    int getNumberOf20s(int amount)
    {
        int numberOfTwenties = amount / 20;
        return numberOfTwenties;
    }

    //Determine the number of 10s to be dispensed
    int getNumberOf10s(int amount)
    {
        amount = amount % 20;
        int numberOfNotes = amount / 10;
        return numberOfNotes;
    }

    //Correct the number of 10s and 20s to be dispensed if there are not enough notes to make the withdrawal
    void correctNumberOfNotes(int &numberOf20s, int &numberOf10s, int &remaining20s)
    {
        numberOf10s += 2*(numberOf20s - remaining20s);
                    numberOf20s = remaining20s;
                    remaining20s = 0;
    }


    int main(void)
    {
        //Declare variables
        int amount;
        int remainingCash;
        int remaining20s = 50;
        int remaining10s = 50;
        int numberOf20s;
        int numberOf10s;
        int withdrawlCount = 0;
        bool cont = true;
    
        while(cont)
        {
            //Display the welcome message
            displayWelcomeMessage();

            //Get the amount the user wants to withdraw
            amount = getWithdrawalAmount();

            //Check if the amount entered is valid
            if (isValidAmount(amount, remainingCash))
            {
                //Incrememnt the withdrawl count
                withdrawlCount++;

                //Determine the number of 20s to be dispensed
                numberOf20s = getNumberOf20s(amount);

                //Determine the number of 10s to be dispensed
                numberOf10s = getNumberOf10s(amount);

                //Correct the number of 10s and 20s if there are not enough
                if (numberOf10s > remaining20s)
                {
                    correctNumberOfNotes(numberOf20s, numberOf10s, remaining20s);
                }

                //Display the number of notes to be dispensed
                cout << "You will receive " << numberOf20s << " 20s, " << numberOf10s << " 10s, " << endl;
            }
            else
            {
                cout << "There is not enough cash available, or the amount requested is invalid.\nEnter a lower and/or valid amount." << endl;
            }

            //Program end conditions
            if (withdrawlCount == 10 || remainingCash == 0)
            {
                cout << "Thank you for using the TMIngram program.\nYou have made " << withdrawlCount << " valid transactions.\n" << endl;
                cout << 50-remaining20s << "20s, and"<< 50-remaining10s << "10s were distributed. That's" << 20*(50-remaining20s)+10*(50-remaining10s) << "$\n" << endl;
                cout << "There are" << (20*remaining20s)+(10*remaining10s) << "$ remaining in the ATM." << endl;
                cont = false;
            }

            
        }

        return 0;
    }

