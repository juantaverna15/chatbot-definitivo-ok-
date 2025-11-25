{$codepage utf8}

unit ChatbotCore;

interface
procedure IniciarChat;

implementation

uses TextUtils, KnowledgeBase;

function EsDespedida(const s: string): boolean;
begin
  EsDespedida := (Pos('salir', s) > 0) or (Pos('chau', s) > 0) or
                 (Pos('adios', s) > 0) or (Pos('adios', RemoveAccents(s)) > 0);
end;


function EsSaludo(tokens: TTokens; count: integer): boolean;
var i: integer;
begin
  EsSaludo := False;
  i := 1;
  while (i <= count) and (not EsSaludo) do
  begin
    if (tokens[i] = 'hola') or (tokens[i] = 'buenas') or
       ((tokens[i] = 'buen') and (i < count) and (tokens[i+1] = 'dia')) then
      EsSaludo := True;
    Inc(i);
  end;
end;


procedure IniciarChat;
var
  entrada, norm: string;
  tokens: TTokens;
  count, i, j, k: integer;
  fin, procesarPregunta: boolean;
  exact, approx, score, maxScore, mejorIndice, bestExact: integer;
  dist: integer;
begin
  WriteLn('¡Hola! Soy tu asistente de informática para principiantes.');
  WriteLn('Preguntame sobre hardware, software, internet, RAM, CPU, archivos, etc.');
  WriteLn('Cuando quieras terminar, escribí "salir", "chau" o "adiós".');

  fin := False;
  while not fin do
  begin
    WriteLn;
    Write('> ');
    ReadLn(entrada);

    { normalización básica para detectar salida }
    norm := ToLowerCase(RemoveAccents(RemovePunctuation(entrada)));
    norm := TrimStr(norm);

    if EsDespedida(norm) then
    begin
      WriteLn('¡Hasta luego! Gracias por conversar.');
      fin := True;
    end
    else
    begin
      { procesamiento PLN }
      norm := ToLowerCase(RemoveAccents(RemovePunctuation(entrada)));
      norm := RemoveStopWords(norm);
      Tokenize(norm, tokens, count);

      if (count = 0) then
      begin
        WriteLn('No entendí tu pregunta, ¿podés reformularla?');
      end
      else
      begin
        { primero manejamos saludos }
        procesarPregunta := True;
        if EsSaludo(tokens, count) then
        begin
          WriteLn('¡Hola! ¿En qué te ayudo?');
          { si la entrada fue solo un saludo, no buscamos en la base }
          if count = 1 then
            procesarPregunta := False;
        end;

        if procesarPregunta then
        begin
          { búsqueda en la base con coincidencias exactas y aproximadas }
          maxScore := 0;
          bestExact := 0;
          mejorIndice := 0;

          for i := 1 to TotalRegistros do
          begin
            exact := 0;
            approx := 0;

            for j := 1 to count do
              for k := 1 to Base[i].keywordCount do
              begin
                if tokens[j] = Base[i].keywords[k] then
                  Inc(exact)
                else
                begin
                  { coincidencia parcial: el token aparece dentro de la keyword }
                  if Pos(tokens[j], Base[i].keywords[k]) > 0 then
                    Inc(exact)
                  else
                  begin
                    dist := LevenshteinDistance(tokens[j], Base[i].keywords[k]);
                    if dist <= 2 then
                      Inc(approx);
                  end;
                end;
              end;

            score := exact * 3 + approx; { prioridad a exactas }
            if (score > maxScore) or ((score = maxScore) and (exact > bestExact)) then
            begin
              maxScore := score;
              bestExact := exact;
              mejorIndice := i;
            end;
          end;

          if (mejorIndice > 0) and (maxScore > 0) then
            WriteLn(Base[mejorIndice].respuesta)
          else
            WriteLn('No entendí tu pregunta, ¿podés reformularla?');
        end;
      end;
    end;
  end;
end;
end.