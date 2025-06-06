from scipy.optimize import linprog
import numpy as np
import re
import subprocess
import pandas as pd
from fractions import Fraction

# Generate the following types of problems:
# 1. LP 3 vars, 3 conditions, positive RHS
# 2. LP 3 vars, 3 conditions, non-positive RHS
# 3. LP 4 vars, 3 conditions, non-positive RHS (to be solved w/ duality
# 4. Fixed text problem

studentList = "studenti.csv"
outputSolutions = "zRezultati.csv" #This .csv will contain the solutions of problems 1-3 for each student
outputHomeworksFolder = "Naloge"


def generateLP(numVar,numCond,positiveRHS=False):
    # Generates a suitable problem (A,b,c) - max c^T x s.t. Ax<=b

    A = np.random.randint(-20,20,(numCond,numVar)) #Matrix entries limited to integers in [-20,19]
    b = np.random.randint(1,20,numCond) #RHS entries

    if not positiveRHS:
        while np.all(b >= 0): # Guarantee a case where two-phase simplex must be used
            b = np.random.randint(-20,20,numCond)
    c = np.random.randint(-20,20, numVar)
    if np.all(c<=0): #In this case the solution is trivial, so try again
        return generateLP(numVar,numCond,positiveRHS)

    # Check if the problem is "too easy" and try again if it is
    if np.count_nonzero(c==0) > 1:
        return generateLP(numVar,numCond,positiveRHS)
    for i in range(numCond):
        if np.count_nonzero(A[i] == 0) > 1:
            return generateLP(numVar, numCond, positiveRHS)

    # -c because the standard form for this library is minimization
    sol = linprog(-c,A,b)
    if sol.status != 0: # We want the solution to exist
        return generateLP(numVar,numCond,positiveRHS)

    z = sol.fun
    if Fraction.from_float(z).limit_denominator().denominator > 15: #The solutions should be relatively simple fractions
        return generateLP(numVar,numCond,positiveRHS)

    return {"A": A, "b" : b, "c" : c, "x" : sol.x, "z" : -z}

def convertToTEX(LP):
    # For a given LP (in the format as returned by generateLP function), generate the .tex for the exercise
    variables = ["x","y","z","w"]
    c = LP["c"]
    A = LP["A"]
    b = LP["b"]

    def stringifyRow(row):
        rowStr = [str(row[j]) + variables[j] for j in range(len(row))]
        for j in range(len(row)):
            if row[j] == 1:
                rowStr[j] = variables[j]
            elif row[j] == -1:
                rowStr[j] = "-" + variables[j]
            elif row[j] == 0:
                rowStr[j] = "\\phantom{0y}"
        return rowStr

    text = "\\begin{alignat*}{" + str(len(c)) +"}\n \\mathrm{max} \\ "
    text += "&+".join(stringifyRow(c)) + "& \\\\ \n"
    for i in range(len(A)):
        row = A[i]

        #trial and error
        if len(c) == 3:
            text += "&+".join(stringifyRow(row)) + "&\\leq" + str(b[i]) + "\\\\"
        elif len(c) == 4:
            text += "&+".join(stringifyRow(row)) + "& &\\leq" + str(b[i]) + "\\\\"
    text = text[:-2] ##remove the \\
    text += "\\end{alignat*}\n"
    text += "\\vspace{-\\baselineskip}"

    text += "\\begin{equation*}\n"
    text += ",".join(variables[:len(c)]) + "\\geq 0"
    text += "\\end{equation*}\n"

    text = re.sub(r'\+-','-',text)
    text = re.sub(r'\+\\phantom{0y}',r'\\phantom{0y}',text)
    return text


def generateHW(name,lastname, outputFolder):
    tex = r"""\documentclass[12pt,letterpaper, onecolumn]{exam}
    \usepackage{amsmath}
    \usepackage{eurosym}
    \usepackage{amssymb}
    \usepackage[T1]{fontenc}
    \usepackage[lmargin=71pt, tmargin=1.2in]{geometry}  %For centering solution box
    \lhead{Leaft Header\\}
    \rhead{Right Header\\}
    % \chead{\hline} % Un-comment to draw line below header
    \pagestyle{empty}   %For removing header/footer from page 1
    
    \begin{document}
    \pointformat{}
    
    \begingroup  
    \centering
    {\small \textsc{Univerzitetni študij finančne matematike} \par}

    {\LARGE \textsc{OPTIMIZACIJSKE METODE}\par}
    {\large \textit{Domača naloga: linearno programiranje} \par}
 \vspace{0.5cm}
    {\Large """
    tex += f"{name} {lastname}"
    tex += r"""\par}
    {\large Rok za oddajo: 7. 4. 2025 \par}
    \rule{\textwidth}{0.4pt}
    \pointsdroppedatright   %Self-explanatory
    \printanswers
    \renewcommand{\solutiontitle}{\noindent\textbf{Ans:}\enspace}   %Replace "Ans:" with starting keyword in solution box
    """

    tex += "\n\\begin{questions}\n"

    tex += "\\question[] S simpleksno metodo reši linearni problem:\n"
    LP1 = generateLP(3,3,True)
    tex += convertToTEX(LP1)
    LP2 = generateLP(3,3)
    tex += "\\question[] S simpleksno metodo reši linearni problem:\n"
    tex += convertToTEX(LP2)

    LP3 = generateLP(4,3)
    tex += "\\question[] S pomočjo duala reši linearni problem:\n"
    tex += convertToTEX(LP3)

    tex += "\\question[]"
    tex+= r"""V norveški smučarskoskakalni reprezentanci iščejo novega šivalca dresov, saj prejšnji ni znal dobro skrivati svojega mojstrstva pred širnim svetom. Iz niti, ki je imamo na voljo $2000\ m$, in osnovnega blaga, ki ga imamo na voljo $500\ m^2$, je treba pripraviti tri vrste posebnega blaga za drese: za trening, tekmo in sodnike. Posebnega blaga vsake vrste potrebujemo vsaj $50\ m^2$, dodatno pa mora biti posebnega blaga za trening vsaj dvakrat toliko kot posebnega blaga za tekmo. Spodnja tabela podaja količine niti in osnovnega blaga, ki jih potrebujemo za kvadratni meter posebnega blaga dane vrste:
    \begin{center}
        \begin{tabular}[htbp]{|l| c c c|}
        \hline
                                    & trening & tekma & sodniki \\
        \hline
        nit $[m / m^2]$				& 4       &  3    &  2      \\
        osnovno blago $[m^2/m^2]$	& 1       &  3   &   2      \\
        \hline
        \end{tabular}
    \end{center}
    (Za kvadratni meter blaga za trening torej potrebujemo $4\ m$ niti in $1\ m^2$ osnovnega blaga.)
    Plačilo, ki ga ponuja reprezentanca, je sledeče:
    \begin{itemize}
        \item $5000$ \euro{} za potne stroške in nastanitev,
        \item $20\ 000$ \euro{} za izdelano posebno blago, katerega skupna površina je največ $200\ m^2$,
        \item če izdelamo več kot $200\ m^2$ metrov blaga, dobimo za vsak dodatni kvadratni meter $100$ \euro{} stimulacije.
    \end{itemize}
    Če torej sešijemo $100\ m^2$ blaga za trening, $50\ m^2$ blaga za tekmo in $50{,}34\ m^2$ blaga za sodnike, dobimo $5000 + 20\ 000 + 34$ evrov. Naša naloga je seveda maksimizirati prihodek.
    \begin{parts}
        \part Predstavi nalogo kot optimizacijski problem.
        \part Pretvori optimizacijski problem v linearnega in ga reši.
        \part Ali je optimalna rešitev ena sama?
        \part Ali bi z dodatno nitjo lahko izdelali več posebnega blaga? Kaj pa z dodatnim osnovnim blagom?
    \end{parts}
    \textbf{Opomba}: Pri tej nalogi je dovoljeno linearen problem reševati tudi s pomočjo računalnika. V kolikor ga ne boš reševal/a na roke, napiši s katero programsko opremo si prišel/la do rešitve.
    """

    tex += "\\end{questions}\n \\end{document}"

    with open(f"temp.tex", "w", encoding="utf-8") as f:
        f.write(tex)

    filename = f"DN1{name.replace(" ","")}_{lastname.replace(" ","")}"
    subprocess.run(['pdflatex', '-jobname', filename, '-output-directory', outputFolder,"temp.tex"], check=True)
    return [LP1["z"],LP2["z"],LP3["z"]]




df = pd.read_csv(studentList,encoding="UTF-8",sep=";")
names = df["Ime"].values
lastNames = df["Priimek"].values
N = len(names)
solutions = np.zeros((N,3))
for i,(name,lastName) in enumerate(zip(names,lastNames)):
    solutions[i] = generateHW(name,lastName, outputHomeworksFolder)
solutions = pd.DataFrame(solutions, columns=['sol1', 'sol2', 'sol3'])
df = pd.concat([df, solutions], axis=1)
df.to_csv(outputSolutions, index=False)
