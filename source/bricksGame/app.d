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
import serpent.physics2d;
import std.path : buildPath;
import bricksGame.idle;

final @serpentComponent struct BrickComponent
{
    int hp = 1;
}

/**
 * Main game logic for the Bricks Demo
 */
final class BrickApp : serpent.App
{

private:

    Scene s;
    Texture ball;
    Texture brick;
    IdleProcessor idleProc;

public:

    this(IdleProcessor proc)
    {
        this.idleProc = proc;
    }

    final void onHitted(Shape a, Shape b)
    {
        idleProc.schedule((view) {
            auto bri = view.data!BrickComponent(a.chipBody.entity);
            bri.hp--;
            if (bri.hp == 0)
            {
                view.killEntity(a.chipBody.entity);
            }
        });
    }

    final override bool bootstrap(View!ReadWrite view)
    {
        context.entity.registerComponent!BrickComponent;

        /* REMOVE SCENE CRUFT FROM SERPENT CORE */
        s = new Scene("main");
        context.display.addScene(s);
        s.addCamera(new OrthographicCamera());

        brick = new Texture(buildPath("assets", "textures", "tileGrey_38.png"),
                TextureFilter.Linear);
        ball = new Texture(buildPath("assets", "textures", "ballGrey_05.png"), TextureFilter.Linear);

        auto col1 = vec4f(1.0f, 1.0f, 0.0f, 1.0f);
        auto col2 = vec4f(0.3f, 1.0f, 0.3f, 1.0f);

        auto offset = 8.0f;

        auto startX = 0.0f;
        auto startY = 100.0f;

        foreach (y; 0 .. 3)
        {
            startX = 150.0f;
            foreach (x; 0 .. 6)
            {

                /* Create sample brick.. */
                auto ent = view.createEntity();
                auto col = ColorComponent();
                auto spri = SpriteComponent();
                auto trans = TransformComponent();
                auto bri = BrickComponent();
                bri.hp = 2;

                spri.texture = brick;
                if (y % 2 == 0)
                {
                    col.rgba = col1;
                    trans.position.z = 0.3f;
                    bri.hp = 1;

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

                auto phys = PhysicsComponent();
                phys.body = new StaticBody();
                auto shape = new BoxShape(brick.width, brick.height, 0.0f);
                shape.elasticity = 1.0f;
                shape.friction = 0.0f;
                phys.body.add(shape);

                phys.body.collision.connect(&onHitted);

                view.addComponent(ent, col);
                view.addComponent(ent, spri);
                view.addComponent(ent, trans);
                view.addComponent(ent, phys);
                view.addComponent(ent, bri);
            }
            startY += brick.height;
            startY -= offset;
        }

        /* Spawn a ball */
        {
            auto ent = view.createEntity();
            auto col = ColorComponent();
            col.rgba = vec4f(1.0f, 1.0f, 1.0f, 1.0f);
            auto spri = SpriteComponent();
            auto trans = TransformComponent();

            spri.texture = ball;
            trans.position.x = 700.0f;
            trans.position.y = 1200.0f;
            trans.position.z = 0.1f;

            trans.scale.x = 0.5f;
            trans.scale.y = 0.5f;
            trans.position.x *= 0.5f;
            trans.position.y *= 0.5f;

            auto phys = PhysicsComponent();
            phys.body = new DynamicBody();
            phys.body.velocity = vec2f(-0.8f, -0.8f);
            auto shape = new CircleShape((ball.width / 2.0f) * trans.scale.x,
                    vec2f((ball.width / 2.0f) * trans.scale.x, (ball.height / 2.0f)) * trans
                    .scale.y);
            shape.mass = 1.0f;
            shape.elasticity = 1.0f;
            shape.friction = 0.0f;
            phys.body.add(shape);

            view.addComponent(ent, col);
            view.addComponent(ent, spri);
            view.addComponent(ent, trans);
            view.addComponent(ent, phys);

        }

        spawnWalls(view);

        return true;
    }

    final EntityID createBarrier(View!ReadWrite view, vec2f pointA, vec2f pointB)
    {
        auto entityID = view.createEntity();
        auto trans = TransformComponent();
        trans.position.x = pointA.x;
        trans.position.y = pointA.y;

        pointB.x -= pointA.x;
        pointB.y -= pointA.y;
        pointA.x = 0.0f;
        pointA.y = 0.0f;

        auto body = new StaticBody();
        auto shape = new SegmentShape(pointA, pointB, 26.0f);
        shape.elasticity = 1.0f;
        shape.friction = 1.0f;
        shape.mass = 300.0f;
        body.add(shape);
        auto phys = PhysicsComponent();
        phys.body = body;

        view.addComponent(entityID, phys);
        view.addComponent(entityID, trans);

        return entityID;
    }

    /**
     * Spawn walls
     */
    final EntityID[] spawnWalls(View!ReadWrite view)
    {
        /* Ensure pixel perfect bounds with extremely thick (26px) segment barriers */
        EntityID[] ret = [
            createBarrier(view, vec2f(0.0f, 0.0f - 26.0f - 13.0f),
                    vec2f(context.display.logicalWidth, 0.0f - 26.0f - 13.0f)), /* top */
            createBarrier(view, vec2f(0.0f, context.display.logicalHeight + 13.0f),
                    vec2f(context.display.logicalWidth, context.display.logicalHeight + 13.0f)), /* bottom */
            createBarrier(view, vec2f(context.display.logicalWidth + 13.0f,
                    0.0f), vec2f(context.display.logicalWidth + 13.0f,
                    context.display.logicalHeight)), /* right */
            createBarrier(view, vec2f(0.0f - 26.0f - 13.0f, 0.0f),
                    vec2f(0.0f - 26.0f - 13.0f, context.display.logicalHeight)), /* left */
        ];

        return ret;
    }
}
