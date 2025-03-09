local lapis = require("lapis")
local db = require("lapis.db")
local bcrypt = require("bcrypt")
local app = lapis.Application()

app:enable("etlua")

-- Login API
app:post("/login", function(self)
    local user = db.select("* FROM users WHERE username = ?", self.params.username)
    if user[1] and bcrypt.verify(self.params.password, user[1].password) then
        return { json = { success = true, rank = user[1].rank, message = "Login succesvol!" } }
    else
        return { json = { success = false, message = "Ongeldige gebruikersnaam of wachtwoord" } }
    end
end)

-- Registratie API
app:post("/register", function(self)
    local existing_user = db.select("* FROM users WHERE username = ?", self.params.username)
    if #existing_user > 0 then
        return { json = { success = false, message = "Gebruikersnaam bestaat al!" } }
    end

    local hashed_password = bcrypt.digest(self.params.password, 12)
    db.insert("users", { username = self.params.username, password = hashed_password, rank = "user" })

    return { json = { success = true, message = "Account succesvol aangemaakt!" } }
end)

return app
