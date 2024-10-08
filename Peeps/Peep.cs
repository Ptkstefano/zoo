using Godot;
using System;

public partial class Peep : CharacterBody2D
{
	private const float SPEED = 15.0f;

	[Export] public Texture2D[] peep_sprites;

	enum PeepStates { IDLE, MOVING, OBSERVING, RESTING }
	private PeepStates peep_state = PeepStates.MOVING;

	//private PeepManager peep_manager;

	private NavigationAgent2D agent;

	private Vector2 position_offset;
	private Vector2 group_position;

	private Texture2D body_texture;
	private Texture2D head_texture;

	private Vector2 move_direction;
	private Vector2 target_pos;
	private Vector2 delta_position;
	private float distance_to_target;
	
	private float look_direction;

	private int frame = 0;
	private int sprite_x = 0;
	private int sprite_y = 0;
	
	private Node helpers;
	private TileMapLayer tileMapRef;
	private Sprite2D peepSprite;

	public override void _Ready()
	{
		helpers = GetNode<Node>("/root/Helpers");
		peepSprite = GetNode<Sprite2D>("PeepSprite");
		tileMapRef = GetNode<TileMapLayer>("/root/TileMapRef");
		GetNode<Timer>("FrameTimer").Timeout += OnFrameTimer;
		SetPeepVisuals();
		GetNode<Timer>("FrameTimer").WaitTime = (float)GD.RandRange(0.4, 0.55);
	}

	//public override void _PhysicsProcess(double delta)
	//{
		//target_pos = group_position + position_offset;
//
		//if (GlobalPosition.DistanceTo(target_pos) < 5)
		//{
			////Velocity = Vector2.Zero;
			//return;
		//}
//
		//move_direction = GlobalPosition.DirectionTo(target_pos);
//
		//if (GlobalPosition.DistanceTo(target_pos) > 25)
			//Velocity = move_direction * SPEED * 2;
		//else
			//Velocity = move_direction * SPEED;
//
		//MoveAndSlide();
	//}
	
	public override void _PhysicsProcess(double delta)
	{
		
		return;
		
		target_pos = group_position + position_offset;
		delta_position = target_pos - GlobalPosition; 

		distance_to_target = delta_position.Length(); 

		if (distance_to_target < 5)
		{
			Velocity = Vector2.Zero;
			return;
		}

		move_direction = delta_position.Normalized();

		Velocity = (distance_to_target > 25) ? move_direction * SPEED * 2 : move_direction * SPEED;

		MoveAndSlide();
	}

	public override void _Process(double delta)
	{
		//if (!GetNode<VisibleOnScreenNotifier2D>("VisibleOnScreenNotifier2D").IsOnScreen())
			return;

		//var helpers = GetNode<Node>("/root/helpers");
		//ZIndex = (int)helpers.Call("get_current_tile_z_index", GlobalPosition);
		
		//tileMapRef

		if (peep_state == PeepStates.MOVING)
		{
			if (Velocity == Vector2.Zero)
			{
				sprite_x = 0;
			}
			else
			{
				if (Velocity.X > 0)
				{
					sprite_x = 2;
					peepSprite.FlipH = true;
				}
				else
				{
					sprite_x = 2;
					peepSprite.FlipH = false;
				}

				if (Velocity.Y > 0)
					sprite_y = 1;
				else if (Velocity.Y < 0)
					sprite_y = 0;
			}
		}
		else if (peep_state == PeepStates.OBSERVING)
		{
			if (Math.Abs(look_direction) > Math.PI * 0.5)
				peepSprite.FlipH = false;
			else
				peepSprite.FlipH = true;

			if (look_direction > 0)
				sprite_y = 1;
			else
				sprite_y = 0;
		}

		peepSprite.FrameCoords = new Vector2I(sprite_x + frame, sprite_y);
	}

	private void OnFrameTimer()
	{
		frame = (frame == 0) ? 1 : 0;
	}

	private void SetPeepVisuals()
	{
		var shader_material = new ShaderMaterial();
		shader_material.Shader = (Shader)GD.Load("res://Peeps/peep.gdshader");

		peepSprite.Texture = peep_sprites[GD.Randi() % peep_sprites.Length];
		
		var colorRefs = GetNode<Node>("/root/ColorRefs");
		
		var bodyColors = (Godot.Collections.Array)colorRefs.Get("body_colors");
		var skinColors = (Godot.Collections.Array)colorRefs.Get("skin_colors");
		var hairColors = (Godot.Collections.Array)colorRefs.Get("hair_colors");
		

		shader_material.SetShaderParameter("body_color", bodyColors[(int)(GD.Randi() % bodyColors.Count)]);
		shader_material.SetShaderParameter("skin_color", skinColors[(int)(GD.Randi() % skinColors.Count)]);
		shader_material.SetShaderParameter("hair_color", hairColors[(int)(GD.Randi() % hairColors.Count)]);

		peepSprite.Material = shader_material;
	}

	//public Vector2 GetNewDestination()
	//{
		//return peep_manager.GeneratePeepDestination();
	//}

	public void ChangeState(int state)
	{
		switch (state)
		{
			case 0: // Stopped
				peep_state = PeepStates.IDLE;
				sprite_x = 0;
				break;
			case 1: // Walking
				peep_state = PeepStates.MOVING;
				sprite_x = 2;
				break;
			case 2: // Observing
				peep_state = PeepStates.OBSERVING;
				sprite_x = GD.Randi() % 2 == 0 ? 4 : 0;
				break;
			case 3: // Sitting
				peep_state = PeepStates.RESTING;
				sprite_x = 6;
				break;
		}
	}
}
