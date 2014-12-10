/* Copyright 2014 Marvin Beckers <beckersmarvin@gmail.com>
*
* This file is part of Calculus.
*
* Calculus is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* Calculus is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with Calculus. If not, see http://www.gnu.org/licenses/.
*/

namespace Calculus.Core {
    public errordomain SCANNER_ERROR {
        UNKNOWN_TOKEN
    }
    
    
    public class Scanner {
        public unowned string str;
        public int pos;
        public unichar[] uc;
        
        public Scanner (string input_str) {
            this.str = input_str;
            this.pos = 0;
            this.uc = new unichar[0];
        }
        
        public static List<Token> scan (string input) throws SCANNER_ERROR {
            Scanner scanner = new Scanner (input);
            TokenType type = TokenType.EOF;
            List<Token> tokenlist = new List<Token> ();
            int index = 0;
            unowned unichar c = 0;
            
            for (int i = 0; input.get_next_char(ref index, out c); i++) {
                scanner.uc.resize (scanner.uc.length + 1);
                scanner.uc[scanner.uc.length - 1] = c;
            }
            
            try {
                while (scanner.pos < scanner.uc.length) {
                    ssize_t start;
                    ssize_t len;
                    string substr = "";
                    
                    type = scanner.next (out start, out len);
                    for (ssize_t i = start; i < (start + len); i++)
                        substr = substr + scanner.uc[i].to_string ();
                    tokenlist.append (new Token (substr, type));
                }
                return tokenlist;
            } catch (SCANNER_ERROR e) { throw e; }
        }
        
        private TokenType next (out ssize_t start, out ssize_t len) throws SCANNER_ERROR {
            while (uc[pos] == ' ' || uc[pos] == '\t')
                pos++;
            start = pos;
            
            if (uc[pos].isdigit ()) {
                while (uc[pos].isdigit ())
                    pos++;
                if (uc[pos] == '.')
                    pos++;
                while (uc[pos].isdigit ())
                    pos++;
                len = pos - start;
                return TokenType.NUMBER;
            } else if (uc[pos].isalpha ()) {
                while (uc[pos].isalpha ())
                    pos++;
                len = pos - start;
                return TokenType.ALPHA;
            } else if (uc[pos] == '(') {
                pos++;
                len = 1;
                return TokenType.P_LEFT;
            } else if (uc[pos] == ')') {
                pos++;
                len = 1;
                return TokenType.P_RIGHT;
            } else if (uc[pos] == '+' || uc[pos] == '-' || uc[pos] == '*' || 
                        uc[pos] == '/' || uc[pos] == '^' || uc[pos] == '%') {
                pos++;
                len = 1;
                return TokenType.OPERATOR;
            } else if (uc[pos] == '√') {
                pos++;
                len = 1;
                return TokenType.FUNCTION;
            } else if (uc[pos] == '\0') {
                len = 0;
                return TokenType.EOF;
            }
            
            //if no rule matches the character at pos, throw an error.
            throw new SCANNER_ERROR.UNKNOWN_TOKEN ("unknown or misplaced character '%s'", str.get_char (pos).to_string ());
        }
    }
}
