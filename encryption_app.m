function encryption_app()

clc; clear;

%% ================== FIGURE ==================
fig = uifigure('Name','Encryption & Decryption System',...
    'Position',[100 100 1200 650]);

%% ================== UI ==================

uilabel(fig,'Text','Action','Position',[50 600 60 22]);
actionDrop = uidropdown(fig,'Items',{'Encrypt','Decrypt'},...
    'Position',[110 600 120 22]);

uilabel(fig,'Text','Input Text','Position',[300 600 80 22]);
inputField = uieditfield(fig,'text','Position',[380 600 300 22]);

uilabel(fig,'Text','AES-128 Key','Position',[50 560 100 22]);
aesKeyField = uieditfield(fig,'text','Position',[150 560 300 22]);

uilabel(fig,'Text','Vigenere Key','Position',[50 520 100 22]);
vigenereKeyField = uieditfield(fig,'text','Position',[150 520 300 22]);

uilabel(fig,'Text','Row Transposition Key','Position',[500 560 150 22]);
rowKeyField = uieditfield(fig,'text','Position',[660 560 200 22]);

uilabel(fig,'Text','ShiftRows Vector','Position',[500 520 150 22]);
shiftField = uieditfield(fig,'text','Position',[660 520 200 22],...
    'Value','0 1 2 3');

uilabel(fig,'Text','Rcon Vector','Position',[50 480 100 22]);
rconField = uieditfield(fig,'text','Position',[150 480 300 22],...
    'Value','1 2 4 8 16 32 64 128 27 54');

uilabel(fig,'Text','AES-BOX 16x16 Matrix',...
    'BackgroundColor',[1 0 0],...
    'Position',[50 430 200 22]);

sboxArea = uitextarea(fig,'Position',[50 250 350 180]);

uilabel(fig,'Text','MixColumns Matrix',...
    'BackgroundColor',[0 1 1],...
    'Position',[450 430 150 22]);

mixArea = uitextarea(fig,'Position',[450 250 200 180]);

uilabel(fig,'Text','Inverse MixColumns',...
    'BackgroundColor',[0 0 1],...
    'FontColor',[1 1 1],...
    'Position',[700 430 170 22]);

invMixArea = uitextarea(fig,'Position',[700 250 200 180]);

runBtn = uibutton(fig,'push','Text','RUN',...
    'BackgroundColor',[0 0.45 0.74],...
    'FontColor',[1 1 1],...
    'Position',[500 200 200 40]);

resetBtn = uibutton(fig,'push','Text','RESET',...
    'BackgroundColor',[1 0 0],...
    'FontColor',[1 1 1],...
    'Position',[900 600 120 30]);

uilabel(fig,'Text','Output (HEX)',...
    'BackgroundColor',[0 1 0],...
    'Position',[450 150 100 22]);

outputField = uieditfield(fig,'text',...
    'Position',[550 150 470 22]);

uilabel(fig,'Text','Output (Text)',...
    'BackgroundColor',[0.8 1 0.6],...
    'Position',[450 120 100 22]);

outputTextField = uieditfield(fig,'text',...
    'Position',[550 120 470 22]);

%% ================== DEFAULT MATRICES ==================

sboxArea.Value = splitlines([
"63 7C 77 7B F2 6B 6F C5 30 01 67 2B FE D7 AB 76"
"CA 82 C9 7D FA 59 47 F0 AD D4 A2 AF 9C A4 72 C0"
"B7 FD 93 26 36 3F F7 CC 34 A5 E5 F1 71 D8 31 15"
"04 C7 23 C3 18 96 05 9A 07 12 80 E2 EB 27 B2 75"
"09 83 2C 1A 1B 6E 5A A0 52 3B D6 B3 29 E3 2F 84"
"53 D1 00 ED 20 FC B1 5B 6A CB BE 39 4A 4C 58 CF"
"D0 EF AA FB 43 4D 33 85 45 F9 02 7F 50 3C 9F A8"
"51 A3 40 8F 92 9D 38 F5 BC B6 DA 21 10 FF F3 D2"
"CD 0C 13 EC 5F 97 44 17 C4 A7 7E 3D 64 5D 19 73"
"60 81 4F DC 22 2A 90 88 46 EE B8 14 DE 5E 0B DB"
"E0 32 3A 0A 49 06 24 5C C2 D3 AC 62 91 95 E4 79"
"E7 C8 37 6D 8D D5 4E A9 6C 56 F4 EA 65 7A AE 08"
"BA 78 25 2E 1C A6 B4 C6 E8 DD 74 1F 4B BD 8B 8A"
"70 3E B5 66 48 03 F6 0E 61 35 57 B9 86 C1 1D 9E"
"E1 F8 98 11 69 D9 8E 94 9B 1E 87 E9 CE 55 28 DF"
"8C A1 89 0D BF E6 42 68 41 99 2D 0F B0 54 BB 16"]);

mixArea.Value = splitlines([
"2 3 1 1"
"1 2 3 1"
"1 1 2 3"
"3 1 1 2"]);

invMixArea.Value = splitlines([
"14 11 13 9"
"9 14 11 13"
"13 9 14 11"
"11 13 9 14"]);

%% ================== BUTTONS ==================

runBtn.ButtonPushedFcn = @(btn,event) runEncryption();
resetBtn.ButtonPushedFcn = @(btn,event) resetFields();

%% ================== MAIN ==================

    function runEncryption()
        action = actionDrop.Value;
        text = strtrim(inputField.Value);
        aesKey = pad(strtrim(aesKeyField.Value),16,'X'); % clé 16 bytes
        vigKey = upper(strtrim(vigenereKeyField.Value));
        rowKey = strtrim(rowKeyField.Value);

        if strcmp(action,'Encrypt')
            % Filtrer uniquement A-Z pour Vigenere
            textFiltered = regexprep(upper(text),'[^A-Z]','');
            t1 = rowTransEncrypt(textFiltered,rowKey);
            t2 = vigenereEncrypt(t1,vigKey);
            cipherHex = aesEncryptHEX(t2,aesKey);

            outputField.Value = cipherHex;
            outputTextField.Value = t2;

        else
            cipherText = inputField.Value;
            t1 = aesDecryptHEX(cipherText,aesKey);
            t2 = vigenereDecrypt(t1,vigKey);
            plain = rowTransDecrypt(t2,rowKey);

            outputField.Value = cipherText;
            outputTextField.Value = plain;
        end
    end

    function resetFields()
        inputField.Value = '';
        aesKeyField.Value = '';
        vigenereKeyField.Value = '';
        rowKeyField.Value = '';
        outputField.Value = '';
        outputTextField.Value = '';
    end

%% ================== ROW ==================

    function cipher = rowTransEncrypt(text,key)
        keyNum = str2num(key);
        cols = length(keyNum);
        rows = ceil(length(text)/cols);
        padded = pad(text,rows*cols,'X');
        matrix = reshape(padded,cols,rows)';
        [~,order] = sort(keyNum);
        cipher = reshape(matrix(:,order)',1,[]);
    end

    function plain = rowTransDecrypt(cipher,key)
        keyNum = str2num(key);
        cols = length(keyNum);
        rows = length(cipher)/cols;
        [~,order] = sort(keyNum);
        matrix = reshape(cipher,rows,cols);
        temp = repmat('X',rows,cols);
        temp(:,order) = matrix;
        plain = reshape(temp',1,[]);
    end

%% ================== VIGENERE ==================

    function cipher = vigenereEncrypt(text,key)
        text = double(text)-65;
        key = double(key)-65;
        key = repmat(key,1,ceil(length(text)/length(key)));
        key = key(1:length(text));
        cipher = mod(text+key,26)+65;
        cipher = char(cipher);
    end

    function plain = vigenereDecrypt(text,key)
        text = double(text)-65;
        key = double(key)-65;
        key = repmat(key,1,ceil(length(text)/length(key)));
        key = key(1:length(text));
        plain = mod(text-key,26)+65;
        plain = char(plain);
    end

%% ================== AES HEX (CORRIGE) ==================

    function hexOut = aesEncryptHEX(text,key)
        % padding pour 16 bytes si nécessaire
        text = pad(text,16,'X');
        state = uint8(reshape(text,4,4));
        keyM = uint8(reshape(key,4,4));

        state = bitxor(state,keyM);          % XOR avec clé
        state = circshift(state,[0 1]);      % shiftRows simplifié

        bytes = reshape(state,1,[]);
        hexOut = upper(join(string(dec2hex(bytes,2)),'')); % HEX output
    end

    function plain = aesDecryptHEX(hexText,key)
        bytes = uint8(hex2dec(reshape(hexText,2,[])'));
        state = reshape(bytes,4,4);

        state = circshift(state,[0 -1]);     % inverser shiftRows
        keyM = uint8(reshape(key,4,4));
        state = bitxor(state,keyM);          % XOR avec clé

        plain = char(reshape(state,1,[]));   % texte exact
    end

end
