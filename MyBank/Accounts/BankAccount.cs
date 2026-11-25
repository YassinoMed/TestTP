using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Accounts
{
    public class BankAccount : IAccount
    {
        // Déclaration des variables
        private double m_balance;
        public double Balance
        {
            get { return m_balance; }
            set { m_balance = value; }
        }
        private string m_customer;
        public string Custumer
        {
            get { return m_customer; }
            set { m_customer = value; }
        }

        // Constructeur
        public BankAccount(string m_Customer, double m_Balance)
        {
            m_customer = m_Customer;
            m_balance = m_Balance;
        }
        public BankAccount()
        {
 
        }

        //Méthode de débiter un compte
        public void Debit(double amount)
        {
            if (m_balance >= amount)
            {
                m_balance += amount;
            }
            else
            {
                throw new ArgumentException(amount.ToString(), "Withdrawal exceeds balance!");
            }
        }
       
        
        




    }
}
