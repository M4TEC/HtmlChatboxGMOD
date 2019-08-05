local function Init()
    surface.CreateFont("HCB_TextEntryFont", {
        font = "Microsoft YaHei",
        extended = false,
        size = 18,
        weight = 500,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })
    if oldAddText == nil then
        oldAddText = chat.AddText
    end
    local teamMessage = false
    function chat.AddText(...)
        local args = {...}
        local processed = {}
        for i=1,#args do
            local arg = args[i]
            if type(arg) == "table" then
                table.insert(processed, arg)
            elseif type(arg) == "Player" then
                table.insert(processed, {
                    ["player"] = true,
                    ["name"] = arg:Name(),
                    ["team"] = {
                        ["id"] = arg:Team(),
                        ["name"] = team.GetName(arg:Team()),
                        ["color"] = team.GetColor(arg:Team())
                    }
                })
            elseif type(arg) == "string" then
                table.insert(processed, arg)
            else
                table.insert(processed, tostring(arg))
            end
        end
        HtmlChatBox:RunJavascript([[addText("]]..util.TableToJSON(processed):JavascriptSafe()..[[")]])
        oldAddText(...)
    end
    if HtmlChatBox and HtmlChatBox.Remove then
        HtmlChatBox:Remove()
        HtmlChatBox = nil
    end
    HtmlChatBox = vgui.Create("DHTML")
    HtmlChatBox:ParentToHUD()
    HtmlChatBox:SetHTML([[
        <html>
            <head>
                <style>
                    * {
                        font-family:Arial,'Microsoft YaHei';
                        -webkit-transition:all .3s linear;
                    }
                    div.chatbox {
                        position:fixed;
                        width:30%;
                        height:180px;
                        background-color:rgba(68,68,68,0);
                        border-radius:5px;
                        bottom:200px;
                        padding:5px;
                    }
                    body.show div.chatbox {
                        background-color:rgba(68,68,68,1);
                    }
                    div.messages {
                        color:white;
                        background-color:rgba(85,85,85,0);
                        border-radius:5px;
                        width:100%;
                        height:144px;
                        overflow:auto;
                        overflow-x:hidden;
                    }
                    body.show div.messages {
                        background-color:rgba(85,85,85,1);
                    }
                    div.messages img {
                        max-width:100%;
                        max-height:140px;
                    }
                    div.messages > p {
                        margin:0;
                        margin-left:3px;
                        margin-top:3px;
                        opacity:0;
                    }
                    body.show div.messages > p {
                        opacity:1;
                    }
                    div.messages::-webkit-scrollbar {
                        width:5px;
                        height:5px;
                    }
                    div.messages::-webkit-scrollbar-thumb {
                        width:5px;
                        height:5px;
                        border-radius:2.5px;
                        background-color:transparent;
                    }
                    body.show div.messages::-webkit-scrollbar-thumb {
                        background-color:#888;
                    }
                    body.show div.messages::-webkit-scrollbar-thumb:hover {
                        background-color:#666;
                    }
                    body.show div.messages::-webkit-scrollbar-thumb:active {
                        background-color:#333;
                    }
                    input.textentry {
                        color:white;
                        opacity:0;
                        background-color:#555;
                        border-radius:5px;
                        border:none;
                        margin-top:5px;
                        width:100%;
                        height:31px;
                        padding:3px;
                        outline:none;
                    }
                    input.textentry.focus {
                        background-color:#6a6a6a;
                    }
                    body.show input.textentry {
                        opacity:1
                    }
                </style>
            </head>
            <body>
                <div class="chatbox">
                    <div class="messages"></div>
                    <input class="textentry" placeholder="输入消息"></input>
                </div>
                <script src="https://cdn.staticfile.org/jquery/1.7.2/jquery.min.js"></script>
                <script>
                    $("input").focus(function() {
                        chatbox.focus();
                        $("input").blur();
                    });
                    /*$(window).keydown(function() {
                        chatbox.focus();
                        $("input").blur();
                    });*/ // Allowed to copy
                    function show() {
                        $("body").addClass("show");
                    }
                    function hide() {
                        losefocus();
                        $("body").removeClass("show");
                    }
                    function focus() {
                        $("input").val(" ");
                        $("input").addClass("focus");
                    }
                    function losefocus(text) {
                        $("input").val(text);
                        $("input").removeClass("focus");
                    }
                    function addText(json) {
                        var args = JSON.parse(json);
                        var p = $("<p></p>");
                        var currentColor = null;
                        for (var i = 0;i<args.length;i++) {
                            var arg = args[i];
                            if (typeof(arg) == "string") {
                                //arg = arg.replace(/<\/?[^>]*script.*?>/g, '');
                                arg = arg.replace(/<\/*?(script|style).*?>/ig, '');// Allowed to use some simple tags
                                arg = arg.replace(/\[滑稽\]/g,"<img src='https://tb2.bdstatic.com/tb/editor/images/face/i_f25.png'/>");
                                arg = arg.replace(/\[洛天依\]/g,"<img src='https://texas.penguin-logistics.cn/wp-content/uploads/2019/07/67857426_p0.png'/>");
                                arg = arg.replace(/\[威胁\]/g,"<img src='https://texas.penguin-logistics.cn/wp-content/uploads/2019/08/GADTFQGS070L2PS2D.jpg'/>");
                                arg = arg.replace(/\[威胁失败\]/g,"<img src='https://texas.penguin-logistics.cn/wp-content/uploads/2019/08/C_2GUUR9XYQXSF8HKC.jpg'/>");
                                arg = arg.replace(/发送图片\[(.*?)\]/g,"<img src='$1'/>");
                                arg = arg.replace(/SendImage\[(.*?)\]/g,"<img src='$1'/>");
                                if (currentColor == null) {
                                    p.append(arg);
                                } else {
                                    currentColor.append(arg);
                                }
                            } else {
                                if (arg.player) {
                                    if (currentColor != null) {
                                        p.append(currentColor);
                                    }
                                    if (arg.team.id != 1001) {
                                        p.append("<span style='color:white;'>[</span>");
                                        currentColor = $("<span style='color:rgba(" + arg.team.color.r + "," + arg.team.color.g + "," + arg.team.color.b + "," + arg.team.color.a + ");'></span>");
                                        currentColor.append(arg.team.name);
                                        p.append(currentColor);
                                        currentColor = null;
                                        p.append("<span style='color:white;'>]&nbsp;</span>");
                                    }
                                    currentColor = $("<span style='color:rgba(" + arg.team.color.r + "," + arg.team.color.g + "," + arg.team.color.b + "," + arg.team.color.a + ");'></span>");
                                    currentColor.append(arg.name);
                                    p.append(currentColor);
                                    currentColor = null;
                                } else {
                                    if (currentColor != null) {
                                        p.append(currentColor);
                                    }
                                    currentColor = $("<span style='color:rgba(" + arg.r + "," + arg.g + "," + arg.b + "," + arg.a + ");'></span>");
                                }
                            }
                        }
                        if (currentColor != null) {
                            p.append(currentColor);
                        }
                        p.css("opacity","1");
                        var scrollBottom = $("div.messages").prop("scrollHeight")-($("div.messages").prop("scrollTop")+144) <= 5;
                        $("div.messages").append(p);
                        if (scrollBottom) {
                            $("div.messages").prop("scrollTop",$("div.messages").prop("scrollHeight"));
                        }
                        setTimeout(function() {
                            p.css("opacity","");
                        },10000);
                        p.find("img").load(function() {
                            if (scrollBottom) {
                                $("div.messages").prop("scrollTop",$("div.messages").prop("scrollHeight"));
                            }
                        });
                    }
                </script>
            </body>
        </html>
    ]])
    function HtmlChatBox:Think()
        self:SetSize(ScrW(),ScrH())
    end
    function HtmlChatBox:OnDocumentReady()
        self:SetAllowLua(true)
        self:AddFunction("chatbox", "focus", function()
            HtmlChatBox.TextEntry:MakePopup()
            HtmlChatBox.TextEntry:RequestFocus()
        end)
    end
    hook.Add( "ChatText", "HCB_ChatText", function(index, name, text, type)
        if type ~= "chat" then
            chat.AddText(text);
        end
    end)
    hook.Add( "HUDShouldDraw", "HCB_Hide", function(name)
        if name == "CHudChat" then
            return false
        end
    end)
    hook.Add( "PlayerBindPress", "HCB_Bind", function( ply, bind, pressed )
        if bind == "messagemode" then
            teamMessage = false
        elseif bind == "messagemode2" then
            teamMessage = true
        else
            return
        end
        HtmlChatBox:MakePopup()
        if HtmlChatBox.TextEntry and HtmlChatBox.TextEntry.Remove then HtmlChatBox.TextEntry:Remove() end
        HtmlChatBox.TextEntry = vgui.Create("DTextEntry", HtmlChatBox)
        HtmlChatBox.TextEntry:SetPos(13,ScrH()-236)
        HtmlChatBox.TextEntry:SetSize(ScrW()*0.3,31)
        HtmlChatBox.TextEntry:SetDrawBackground(false)
        HtmlChatBox.TextEntry:SetDrawBorder(false)
        HtmlChatBox.TextEntry:SetTextColor(Color(255,255,255))
        HtmlChatBox.TextEntry:SetCursorColor(Color(255,255,255))
        HtmlChatBox.TextEntry:SetFont("HCB_TextEntryFont")
        HtmlChatBox.TextEntry:SetZPos(1)
        function HtmlChatBox.TextEntry:OnGetFocus()
            HtmlChatBox:RunJavascript("focus()")
        end
        function HtmlChatBox.TextEntry:OnLoseFocus()
            HtmlChatBox:RunJavascript("losefocus(\""..self:GetValue():JavascriptSafe().."\")")
        end
        function HtmlChatBox.TextEntry:OnKeyCodeTyped(key)
            if key == KEY_ESCAPE then
                HtmlChatBox:SetMouseInputEnabled(false)
                HtmlChatBox:SetKeyBoardInputEnabled(false)
                gui.HideGameUI()
                HtmlChatBox:RunJavascript([[hide()]])
                self:Remove()
            elseif key == KEY_ENTER then
                LocalPlayer():ConCommand([[say "]]..HtmlChatBox.TextEntry:GetValue()..[["]])
                HtmlChatBox:SetMouseInputEnabled(false)
                HtmlChatBox:SetKeyBoardInputEnabled(false)
                HtmlChatBox:RunJavascript([[hide()]])
                self:Remove()
            end
        end
        HtmlChatBox.TextEntry:MakePopup()
        HtmlChatBox:RunJavascript([[show()]])
        return true
    end)
end
hook.Add("InitPostEntity","HCB_Init",Init)
Init()