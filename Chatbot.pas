{$codepage utf8}

program Chatbot;

uses ChatbotCore, KnowledgeBase;

begin
  CargarBase('kb.txt');
  IniciarChat;
end.
