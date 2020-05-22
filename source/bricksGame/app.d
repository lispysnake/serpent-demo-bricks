/*
 * This file is part of serpent.
 *
 * Copyright © 2019-2020 Lispy Snake, Ltd.
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

module bricksGame.app;

import serpent;
import std.path : buildPath;

/**
 * Main game logic for the Bricks Demo
 */
final class BrickApp : serpent.App
{

private:

    Scene s;
    Texture brick;

public:

    final override bool bootstrap(View!ReadWrite view)
    {
        /* REMOVE SCENE CRUFT FROM SERPENT CORE */
        s = new Scene("main");
        context.display.addScene(s);
        s.addCamera(new OrthographicCamera());

        brick = new Texture(buildPath("assets", "textures", "tileGrey_38.png"));

        auto col1 = vec4f(1.0f, 1.0f, 0.0f, 1.0f);
        auto col2 = vec4f(0.3f, 1.0f, 0.3f, 1.0f);

        auto offset = 8.0f;

        auto startX = 0.0f;
        auto startY = 0.0f;

        foreach (y; 0 .. 3)
        {
            startX = 0.0f;
            foreach (x; 0 .. 6)
            {

                /* Create sample brick.. */
                auto ent = view.createEntity();
                auto col = ColorComponent();
                auto spri = SpriteComponent();
                auto trans = TransformComponent();

                spri.texture = brick;
                if (y % 2 == 0)
                {
                    col.rgba = col1;
                    trans.position.z = 0.3f;

                }
                else
                {
                    col.rgba = col2;
                    trans.position.z = 0.2f;
                }
                trans.position.x = startX;
                trans.position.y = startY;

                if (x > 0)
                {
                    trans.position.x -= offset;
                }
                if (y > 0)
                {
                    trans.position.y -= offset;
                }

                startX += brick.width;
                startX -= offset;

                trans.position.x *= 0.7f;
                trans.position.y *= 0.7f;
                trans.scale.x = 0.7f;
                trans.scale.y = 0.7f;

                view.addComponent(ent, col);
                view.addComponent(ent, spri);
                view.addComponent(ent, trans);
            }
            startY += brick.height;
            startY -= offset;
        }

        return true;
    }
}
