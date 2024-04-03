# OOP

## Introduzione
Ai tempi di Simula e del primo Smalltalk, molto molto tempo prima di Python,
Ruby, Perl e SLDJ, i programmatori Lisp già producevano una pletora 
di linguaggi object oriented. Il vostro progetto consiste nella costruzione 
di un’estensione “object oriented” di Common Lisp, chiamata OOΛ, e 
di un’estensione “object oriented” di Prolog, chiamata OOΠ.

## Primitive
**'def_class/3'**: definisce una classe e la memorizza nella base di 
conoscenza di prolog. è presente, per maggiore comodità e flessibilità, 
un predicato equivalente 'def_class/2' utilizzato per definire classi 
senza fields. Questo predicato si occupa inoltre di caricare nella base 
anche eventuali metodi della classe

**'make/3'**: crea un istanza di una classe e la memorizza nella base di 
conoscenza di prolog. è presente, per maggiore comodità e flessibilità,
un predicato equivalente 'make/2' utilizzto per definire istanze senza 
modificare fields della classe e usare i valori default

**'is_class/1'**: restituisce true nel caso in cui il nome passato 
sia il nome di una classe presente nella base di conoscenza

**'is_instance/1'**: restituisce true nel caso in cui il nome passato 
sia il nome di una istanza presente nella base di conoscenza di 
qualunque classe

**'is instance/2'**: restituisce true nel caso in cui il nome passato 
sia il nome di una istanza presente nella base di conoscenza 
della specifica classe passata come secondo argomento

**'inst/2'**: restituisce (se presente nella base di conoscenza) 
l'istanza collegata al nome passato come primo argomento

**'field/3'**: estrae il valore di un campo (field) da un'istanza passata. 
Può essere passato sia il nome dell'istanza sia l'istanza intera. Nel 
caso in cui l'istanza passata non ha modificato il valore del field, esso 
sarà estratto dalla sua classe o dalle sue classi antenate

**'fieldx'**: estrae il valore da una classe percorrendo una catena 
di attributi

### Predicati Aggiuntivi
**'is_superclass/2'**: Controlla le gerarchie tra classi.

**'list_of_atoms/1'**: Verifica che ogni componente di una lista sia un atomo.

**'list_of_terms/2'**: Controlla che ogni componente di una lista sia un 
termine (non atomo), specificamente un campo (field) o un metodo. Nel 
caso di un metodo esso sarà gestito di conseguenza, nel caso di un campo 
saranno effettuati degli eventuali controlli sul suo tipo detttati dai gli 
antenati della classe

**'verify_field_class/2'**: Verifica se il campo (field) della classe 
è già presente nei suoi antenati, e in tal caso controlla se il campo 
ha un tipo specificato da una classe antenata. Per verificarne effettivamente 
il tipo viene richiamato il predicato 'class_field_type/2'

**'class_field_type/2'**: verifica che il field di una classe passato 
rispetti i vincoli sul tipo dettati dai suoi antenati

**'get_field_value'**: Restituisce il valore di un campo (field) dato 
il suo nome.

**'get_class_parts'**: Restituisce campi (e metodi) di una classe data.

**'get_parents_parts'**: Restituisce (se ci sono) le parti (campi e metodi) 
dei genitori di una classe.

**'get_superclasses/2'**: Restituisce la lista di antenati (mediante il 
predicato 'superclass/2') di una classe senza duplicati

**'superclass/2'**: Restituisce la lista di antenati di una classe o 
una lista di classi passata

**'has_type/2'**: Verifica se i campi di una classe richiedano un tipo 
specifico di dato, ed in caso verifica che i field dell'istanza passata 
li rispettino tramite il predicato 'check_type/2'. Inoltre è presente 
una variante del predicato la quale estrae i valori che gli sevono 
direttamente da un'istanza

**'get_class_field/3'**: Restituisce, se presente, il campo di una classe 
dato il suo nome

**'check_type/2'**: Verifica che l'argomento passato rispetti il tipo di dato 
specificato. Questo predicato verifica sia tipi di dato base del prolog 
sia classi specificate nell'estensione

**'subtypep/2'**: Verifica che il primo elemento sia un sottotipo del 
secondo elemento

**'create_method/3'**: Prepara e salva un metodo nella base di conoscenza

**'create_head'**: Utilizzato da 'create_method' per creare l'intestazione
del metodo con gli (eventuali) argomenti passati.

**'substring_replace/4'**: Sostituisce una data sottostringa con un'altra, 
restituendo la stringa iniziale modificata.

**'substring_replace_scroll/5'**: Serve a 'substring_replace/4' per 
scorrere tutte le occorrenze nella stringa di partenza.

## Test Effettuati
Per testare (e debuggare...) il codice sono stati eseguiti tutti i test 
forniti nella consegna del progetto, oltre a qualche test minore per 
specifiche parti di codice:

?- def_class(person, [], [field(name, 'Eve'), field(age, 21, integer)]).\
*true*.

?- def_class(student, [person], [field(name, 'Eva Lu Ator'), field(university, 'Berkeley'), method(talk, [], (write('My name is '), field(this, name, N), writeln(N), write('My age is '), field(this, age, A), writeln(A)))]).\
*true*.

?- make(eve, person).\
*true*.

?- make(adam, person, [name = 'Adam']).\
*true*.

?- make(s1, student, [name = 'Eduardo De Filippo', age = 108]).\
*true*.

?- make(s2, student).\
*true*

?- make(s3, student, [name = 'Harry Potter', age = "12"]).\
*false*

?- field(eve, age, A).\
*A = 21*.

?- field(s1, age, A).\
*A = 108.*

?- field(s2, name, N).\
*N = 'Eva Lu Ator'*.

?- field(eve, address, Address).\
*false*.

?- talk(s1).\
**My name is Eduardo De Filippo\
My age is 108**.

?- talk(eve).\
*false.*

?- def_class(studente_bicocca, [student], [method(talk, [], (write('Mi chiamo '), field(this, name, N), writeln(N), writeln('e studio alla Bicocca.'))), method(to_string, [ResultingString], (with_output_to(string(ResultingString), (field(this, name, N), field(this, university, U), format('#<~w Student ~w>', [U, N]))))), field(university, 'UNIMIB')]).\
*true.*

?- make(ernesto, studente_bicocca, [name = 'Ernesto']).\
*true.*

?- talk(ernesto).\
**Mi chiamo Ernesto\
e studio alla Bicocca**.

?- to_string(ernesto, S).\
*S = "\#\<UNIMIB Student Ernesto>".*

?- def_class(test_class, [], [field(value, undefined)]).\
*true.*

?- make(alfa, test_class, [value = 'Trovato!']).\
*true.*

?- make(bravo, test_class, [value = alfa]).\
*true.*

?- make(charlie, test_class, [value = bravo]).\
*true.*

?- fieldx(charlie, [value, value, value], Result).\
*Result = 'Trovato!'.*

?- def_class(using_integers, [], [field(x, 41, integer)]).\
**true.**

?- def_class(using_reals, [using_integers], [field(x, 42.0, float)]).\
false.*

?- def_class(a, [], [field(numero, 8, integer)]).
true.

?- def_class(b, [a], [field(numero, 9)]).
true.

?- def_class(c, [b], [field(numero, "Ciao", string)]).
false.

?- def_class(person, [], [field(name, "Sam"), field(age, 20, integer)]).

?- def_class(student, [person], [field(university, "Bicocca")]).

?- def_class(other, [], [field(user, undefined, student), method(talk, [], (write('Universita: '), fieldx(this, [user, university], R), write(R)))]).

?- make(s, student).

?- make(o, other, [user=s]).

talk(o).
Universita': Bicocca.

## Crediti
* Melon Cristiano 899647
* Teodori Alessandro 899894