<?php

namespace Database\Seeders\Quran\HaramCode;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class HaramCodeSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $haramCode = [[
            "code" => "E100",
            "item_name" => "Curcumin/Turmeric",
            "info" =>
                "Colour Halal only if they are 100% but in food industry they are not available 100% but made with fat based emulsifiers such as Polysorbate 80",
            "status" =>
                "MUSHBOOH: Halal if pure grind turmeric powder or granular. Mushbooh if used as liquid, the solvents has to be Halal. Haram if hidden ingredient is pork fat based emulsifier in dry mix.",
        ],
            [
                "code" => "E101",
                "item_name" => "Riboflavin (Vitamin B2)",
                "info" => "Colour",
                "status" =>
                    "Mushbooh:(Haram if from pork liver & Kidney, Halal if 100% plant material",
            ],
            [
                "code" => "E102",
                "item_name" => "Tartrazine",
                "info" => "Colour",
                "status" =>
                    "Mushbooh: Halal if used as 100% dry colour. Mushbooh if used as liquid colour, the solvent has to be Halal",
            ],
            [
                "code" => "E103",
                "item_name" => "Chrysoine Resocinol",
                "info" => "Colour",
                "status" =>
                    "Mushbooh: This is colouring E-Number but Halal only if the solvents are Halal. It is obtained from a plant.",
            ],
            [
                "code" => "E104",
                "item_name" => "Quinoline Yellow",
                "info" => "Colour",
                "status" =>
                    "Mushbooh: Halal if used as 100% dry colour. Mushbooh if used as liquid colour, the solvent other than water has to be Halal",
            ],
            [
                "code" => "E110",
                "item_name" => "Sunset Yellow FCF / Orange Yellow S",
                "info" => "Colour",
                "status" =>
                    "Mushbooh: Halal if used as 100% dry colour. Mushbooh if used as liquid colour, the solvent has to be Halal",
            ],
            [
                "code" => "E120",
                "item_name" => "Cochineal / Carminic Acid",
                "info" =>
                    "Colour - Obtained from insects. All insects except Locust are Haram in Islam.",
                "status" => "Haram according to Hanafi Fiqqah",
            ],
            [
                "code" => "E132",
                "item_name" => "Indigo Carmine / Idigotine",
                "info" =>
                    "Colour It is used to be extracted from plant but now it is synthetically produced and It is Halal if synthetically produced from Halal sources. Liquid for requires solvent, liquid for is Halal only if Halal solvent are used.",
                "status" =>
                    "MUSHBOOH: Halal if use as is as a 100% synthetic colour but if pork glycerin is added as a solvent then it is Haram",
            ],
            [
                "code" => "E140",
                "item_name" => "Chlorophyll",
                "info" =>
                    "Colour - It is a plant pigment and Halal only if extracting solvents are Halal not alcohol.",
                "status" =>
                    "MUSHBOOH: Halal if use 100% powder or Halal if water or vegetable oil was used as a solvent",
            ],
            [
                "code" => "E141",
                "item_name" => "Copper Complex of Chlorophyll",
                "info" =>
                    "Colour It is a plant pigment and Halal only if extracting solvents are Halal not alcohol.",
                "status" =>
                    "MUSHBOOH: Halal if use 100% powder or Halal if water or vegetable oil was used as a solvent",
            ],
            [
                "code" => "E160 (a)",
                "item_name" => "Alpha, Beta, Gamma Carotene",
                "info" =>
                    "Colour - Carotene Carotene Colour is obtained from plant source but it is not available in 100% form because it is not soluble in water. Gelatin is added to help mix in liquid products. In USA fish gelatin is used so it is Halal in USA but in UK they may not use fish gelatin but may use gelatin from pork or beef.",
                "status" =>
                    "MUSHBOOH: Halal if used as 100% dry Colour If used as liquid Colour, the solvent has to be Halal",
            ],
            [
                "code" => "E160 (e)",
                "item_name" => "Beta-apo-8-carotenal",
                "info" =>
                    "Colour - Carotene arotene colour is obtained from plant source but it is not available in 100% form because it is not soluble in water. Gelatin is added to help mix in liquid products. In USA fish gelatin is used so it is Halal in USA but in UK they may not use fish gelatin but may use gelatin from pork or beef.",
                "status" =>
                    "MUSHBOOH: Halal if used as 100% dry powder or granular or Halal if vegetable oil is used as a solvent in liquid form as a hidden ingredient. Haraam if pork gelatin is used as hidden ingredient or carrier",
            ],
            [
                "code" => "E160 (f)",
                "item_name" => "Ethyl ester of Beta-apo-8-cartonoic acid",
                "info" =>
                    "Colour - Carotene arotene colour is obtained from plant source but it is not available in 100% form because it is not soluble in water. Gelatin is added to help mix in liquid products. In USA fish gelatin is used so it is Halal in USA but in UK they may not use fish gelatin but may use gelatin from pork or beef.",
                "status" =>
                    "MUSHBOOH: Halal if used as 100% dry powder or granular or Halal if vegetable oil is used as a solvent in liquid form as a hidden ingredient. Haraam if pork gelatin is used as hidden ingredient or carrier ",
            ],
            [
                "code" => "E161 (a)",
                "item_name" => "Flavoxanthin",
                "info" =>
                    "Colour- It is a natural pigment. Halal status is depend upon (a) what extracting material used to obtained the pigment (b) what solvent used for its liquid form.",
                "status" =>
                    "MUSHBOOH: Halal if used as 100% dry Colour If used as liquid Colour, the solvent has to be Halal",
            ],
            [
                "code" => "E161 (b)",
                "item_name" => "Lutein",
                "info" =>
                    "Colour - Lutein is xanthophyll carotene. It is present in plant as fatty acid ester. It is extrcted from marigold petals. Its Halal status depend upon the Halal status of extracting chemicals, if it is extracted by alcohol then it is not Halal",
                "status" =>
                    "MUSHBOOH: Halal if used as 100% dry powder or granular. Haram if pork gelatin or pork glycerin is added in dry or liquid form ",
            ],
            [
                "code" => "E161 (c)",
                "item_name" => "Cryptoxanthin",
                "info" =>
                    "Colour - Cryptoxanthin is a natural carotene pigment and it is found in petal of flower of plants. Its Halal status depend upon the Halal status of extracting chemicals, if it is extracted by alcohol then it is not Halal.",
                "status" =>
                    "MUSHBOOH: Halal if used as 100% dry Colour If used as liquid Colour, the solvent has to be Halal",
            ],
            [
                "code" => "E161 (d)",
                "item_name" => "Rubixanthin",
                "info" =>
                    "Colour - Rubixanthin is a xanthophyl pigment of plants. Its Halal status is depend upon extracting chemicals and solvents used in its liquid form",
                "status" =>
                    "MUSHBOOH: Halal if used as 100% dry Colour If used as liquid Colour, the solvent has to be Halal",
            ],
            [
                "code" => "E161 (e)",
                "item_name" => "Violaxanthin",
                "info" =>
                    "Colour - violaxanthin is a xanthophyl pigment of plants. Its Halal status is depend upon extracting chemicals and solvents used in its liquid form",
                "status" =>
                    "MUSHBOOH: Halal if used as 100% dry Colour If used as liquid Colour, the solvent has to be Halal",
            ],
            [
                "code" => "E161 (f)",
                "item_name" => "Rhodoxanthin",
                "info" =>
                    "Colour - Rhodoxanthin is a xanthophyl pigment of plants. Its Halal status is depend upon extracting chemicals and solvents used in its liquid form",
                "status" =>
                    "MUSHBOOH: Halal if used as 100% dry Colour If used as liquid Colour, the solvent has to be Halal",
            ],
            [
                "code" => "E161 (g)",
                "item_name" => "Canthaxanthin",
                "info" =>
                    "Colour - Canthaxanthin is a carotene pigment of plants. Its Halal status is depend upon extracting chemicals and solvents used in its liquid form.",
                "status" =>
                    "MUSHBOOH: Halal if used as 100% dry Colour If used as liquid Colour, the solvent has to be Halal",
            ],
            [
                "code" => "E214",
                "item_name" => "Ethyl 4-hydroxybenzoate",
                "info" => "Preservative",
                "status" =>
                    "MUSHBOOH: Halal, if used as 100% dry powder or granular. Haram if alcohol is used as a solvent ",
            ],
            [
                "code" => "E215",
                "item_name" => "Ethyl 4-hydroxybenzoate, Sodium Salt",
                "info" => "Preservative",
                "status" =>
                    "Halal, if used as 100% dry powder or granular. Haraam if alcohol is used as a solvent ",
            ],
            [
                "code" => "E216",
                "item_name" => "Propyl 4-hydroxybenzoate",
                "info" => "Preservative",
                "status" =>
                    "MUSHBOOH: Halal, if used as 100% dry powder or granular. Haram if alcohol is used as a solvent ",
            ],
            [
                "code" => "E217",
                "item_name" => "Propyl 4-hydroxybenzoate, Sodium Salt",
                "info" => "Preservative",
                "status" =>
                    "MUSHBOOH: Halal, if used as 100% dry powder or granular. Haraam if alcohol is used as a solvent ",
            ],
            [
                "code" => "E218",
                "item_name" => "Methyl 4-hydroxybenzoate",
                "info" => "Preservative",
                "status" =>
                    "MUSHBOOH: Halal, if used as 100% dry powder or granular. Haram if alcohol is used as a solvent ",
            ],
            [
                "code" => "E219",
                "item_name" => "Methyl 4-hydroxybenzoate, Sodium Salt",
                "info" => "Preservative",
                "status" =>
                    "MUSHBOOH: Halal, if used as 100% dry powder or granular. Haram if alcohol is used as a solvent ",
            ],
            [
                "code" => "E252",
                "item_name" => "Potassium Nitrate (Saltpetre)",
                "info" => "Chemical Preservative",
                "status" =>
                    "MUSHBOOH: Try to avoid it, as it may contain PIG FAT (most probably)",
            ],
            [
                "code" => "E304",
                "item_name" => "Ascorbyl Palmitate",
                "info" => "Antioxidants- Vitamin C and derivatives",
                "status" =>
                    "MUSHBOOH: Halal if saturated fatty acid Palmitic acid is obtained from plant. Haram if palmitic acid is obtained from pork fat",
            ],
            [
                "code" => "E306",
                "item_name" => "Natural Extracts rich in Tocopherols",
                "info" => "Antioxidants- Vitamin E",
                "status" =>
                    "MUSHBOOH: Halal If Tocopherol is obtained from plant fat. Haraam if Tocopherol is obtained from pork fat ",
            ],
            [
                "code" => "E312",
                "item_name" => "Dodecyl Gallate",
                "info" => "Antioxidants- other",
                "status" =>
                    "Halal if obtained from nutgalls or plant secretion. Haram if alcohol was used as solvent",
            ],
            [
                "code" => "E320",
                "item_name" => "Butylated Hydroxyanisole (BHA)",
                "info" => "Antioxidants- other",
                "status" =>
                    "MUSHBOOH: Halal if only vegetable oil is used as a carrier. Haraam if the carrier is from pork fat. It is not available as pure 100% chemical. ",
            ],
            [
                "code" => "E321",
                "item_name" => "Butylated Hydroxytoluene (BHT)",
                "info" => "Antioxidants- other",
                "status" =>
                    "MUSHBOOH: Halal if only vegetable oil is used as a carrier. Haram if the carrier is from pork fat. It is not available as pure 100% chemical.",
            ],
            [
                "code" => "E422",
                "item_name" => "Glycerol",
                "info" =>
                    "Glycerol is a polyol obtained from fats and oil. It is Halal if it obtained from oils or soy fat. Suitable for vegetarian label indicates that only vegetable oil or fat is used as a source.",
                "status" =>
                    "MUSHBOOH: called Glycerin in USA, Halal if it is from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E430",
                "item_name" => "Polyoxyethane (8) Stearate",
                "info" =>
                    "Emulsifiers and Stabilizers - Fatty Acid derivatives. Suitable for vegetarian label indicates that only vegetable fat is used as a source",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E431",
                "item_name" => "Polyoxyethane (40) Stearate",
                "info" =>
                    "Emulsifiers and Stabilizers - Fatty Acid derivatives. Suitable for vegetarian label indicates that only vegetable fat is used as a source.",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E432",
                "item_name" => "Polyoxyethane (20) Sorbitan / Polysorbate 20",
                "info" => "Emulsifiers and Stabilizers - Fatty Acid derivatives",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E433",
                "item_name" => "Polyoxyethane (20) Sorbitan Mono-oleate / Polysorbate 80",
                "info" =>
                    "Emulsifiers and Stabilizers - Fatty Acid derivatives. Suitable for vegetarian label indicates that only vegetable fat is used as a source.",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E434",
                "item_name" => "Polyoxyethane (20) Sorbitan Monopalmitate / Polysorbate 40",
                "info" => "Emulsifiers and Stabilizers - Fatty Acid derivatives",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E435",
                "item_name" => "Polyoxyethane (20) Sorbitan Monostearate / Polysorbate 60",
                "info" =>
                    "Emulsifiers and Stabilizers - Fatty Acid derivatives. Suitable for vegetarian label indicates that only vegetable fat is used as a source",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E436",
                "item_name" => "Polyoxyethane (20) Sorbitan Tristearate / Polysorbate 65",
                "info" =>
                    "Emulsifiers and Stabilizers - Fatty Acid derivatives. Suitable for vegetarian label indicates that only vegetable fat is used as a source.",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E441",
                "item_name" => "Gelatin",
                "info" => "Thickeners, gelling agents, phosphates, humectants, emulsifiers",
                "status" =>
                    "MUSHBOOH: Gelatin from Zabiha (Halal way) slaughtered beef and fish source is considered Halal. Gelatin from pork is Haram. Gelatin from non zabiha (Non Halal way) beef is not Halal.",
            ],
            [
                "code" => "E470",
                "item_name" => "Sodium, Potassium and Calcium Salts of Fatty Acids",
                "info" =>
                    "Emulsifiers and Stabilizers - salts or Esters of Fatty Acids. Suitable for vegetarian label indicates that only vegetable fat is used as a source.",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E471",
                "item_name" => "Mono-and Diglycerides of Fatty Acids",
                "info" =>
                    "Emulsifiers and Stabilizers - salts or Esters of Fatty Acids. If the fat source is from soy fat then it is Halal. If it is from pork fat then it is Haram. If it is from non zabiha (Non Hala Way) beef then it is not Halal. If a claim appeared on food package 'Suitable for Vegetarian' containing E-Number 471 then it means the E Number 471 is from soy fat. The food product is Halal if all other ingredients are Halal",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E472",
                "item_name" => "Various Esters of Mono-and Diglycerides of Fatty Acids",
                "info" =>
                    "Emulsifiers and Stabilizers - salts or Esters of Fatty Acids If the fat source is from soy fat then it is Halal. If it is from pork fat then it is Haram. If it is from non zabiha (Non Hala Way) beef then it is not Halal. If a claim appeared on food package 'Suitable for Vegetarian' containing E-Number 472 then it means the E Number 472 is from soy fat. The food product is Halal if all other ingredients are Halal",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E473",
                "item_name" => "Sucrose Esters of Fatty Acids",
                "info" =>
                    "Emulsifiers and Stabilizers - salts or Esters of Fatty Acids. If the fat source is from soy fat then it is Halal. If it is from pork fat then it is Haram. If it is from non zabiha beef then it is not Halal. If a claim appeared on food package 'Suitable for Vegetarian' containing E-Number 473 the it means the E Number 473 is from soy fat. The food product is Halal if all other ingredients are Halal",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E474",
                "item_name" => "Sucroglycerides",
                "info" =>
                    "Emulsifiers and Stabilizers - salts or Esters of Fatty Acids. Suitable for vegetarian label indicates that only vegetable fat is used as a source",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E475",
                "item_name" => "Polyglycerol Esters of Fatty Acids",
                "info" =>
                    "Emulsifiers and Stabilizers - salts or Esters of Fatty Acids. Suitable for vegetarian label indicates that only vegetable fat is used as a source",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E476",
                "item_name" => "Polyglycerol Esters of Polycondensed Esters of Caster Oil",
                "info" =>
                    "Emulsifiers and Stabilizers - salts or Esters of Fatty Acids. Suitable for vegetarian label indicates that only vegetable fat is used as a source.",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E477",
                "item_name" => "Propane-1,2-Diol Esters of Fatty Acids",
                "info" =>
                    "Emulsifiers and Stabilizers - salts or Esters of Fatty Acids. Suitable for vegetarian label indicates that only vegetable fat is used as a source.",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E478",
                "item_name" =>
                    "Lactylated Fatty Acid Esters of Glycerol and Propane-1,2-Diol",
                "info" =>
                    "Emulsifiers and Stabilizers - salts or Esters of Fatty Acids. Suitable for vegetarian label indicates that only vegetable fat is used as a source",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E481",
                "item_name" => "Sodium Stearoyl-2-Lactylate",
                "info" =>
                    "Emulsifiers and Stabilizers - salts or Esters of Fatty Acids. Suitable for vegetarian label indicates that only vegetable fat is used as a source.",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E482",
                "item_name" => "Calcium Stearoyl-2-Lactylate",
                "info" =>
                    "Emulsifiers and Stabilizers - salts or Esters of Fatty Acids. Suitable for vegetarian label indicates that only vegetable fat is used as a source",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E483",
                "item_name" => "Stearyl Tartrate",
                "info" =>
                    "Emulsifiers and Stabilizers - salts or Esters of Fatty Acids. Suitable for vegetarian label indicates that only vegetable fat is used as a source.",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E491",
                "item_name" => "Sorbitan Monostearate",
                "info" =>
                    "Emulsifiers and Stabilizers - salts or Esters of Fatty Acids. Suitable for vegetarian label indicates that only vegetable fat is used as a source.",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E492",
                "item_name" => "Sorbitan Tristearate",
                "info" =>
                    "Emulsifiers and Stabilizers - salts or Esters of Fatty Acids. Suitable for vegetarian label indicates that only vegetable fat is used as a source.",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E493",
                "item_name" => "Sorbitan Monolaurate",
                "info" =>
                    "Emulsifiers and Stabilizers - salts or Esters of Fatty Acids. Suitable for vegetarian label indicates that only vegetable fat is used as a source.",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E494",
                "item_name" => "Sorbitan Mono-oleate",
                "info" =>
                    "Emulsifiers and Stabilizers - salts or Esters of Fatty Acids. Suitable for vegetarian label indicates that only vegetable fat is used as a source",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E495",
                "item_name" => "Sorbitan Monopalmitate",
                "info" =>
                    "Emulsifiers and Stabilizers - salts or Esters of Fatty Acids. Suitable for vegetarian label indicates that only vegetable fat is used as a source.",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E496",
                "item_name" => "Sorbitan Trioleate",
                "info" =>
                    "E-Number 496 is Sorbitan Trioleate Emulsifiers and Stabilizers - salts or Esters of Fatty Acids. Suitable for vegetarian label indicates that only vegetable fat is used as a source",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E542",
                "item_name" => "Edible Bone Phosphate (Bone-Meal)",
                "info" =>
                    "Miscellaneous - Anti-Caking Agents Halal if the bones from zabiha (Halal Way) slaughtered beef.",
                "status" =>
                    "MUSHBOOH: If it is from Zabiha (Halal way) slaughtered beef  source is considered Halal. If it is fromfrom non zabiha (Non Halal way) beef is not Halal.",
            ],
            [
                "code" => "E544",
                "item_name" => "Calcium Polyphosphates",
                "info" => "Miscellaneous - Anti-Caking Agents",
                "status" =>
                    "Mushbooh: Halal if it is from minerals, Haram if it is from pig bones",
            ],
            [
                "code" => "E570",
                "item_name" => "Stearic Acid",
                "info" =>
                    "Miscellaneous - other compounds. Siutable for vegetarian label on the package indicates the source of Stearic acid is from vegetable fat.",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E572",
                "item_name" => "Magnesium Stearate",
                "info" =>
                    "Miscellaneous - other compounds. Suittable for vegetarian label on the package indicates the source of Magnesium Stearate is from vegetable fat.",
                "status" =>
                    "MUSHBOOH: Halal if it is 100% from plant fat, Haram if it is from pork fat",
            ],
            [
                "code" => "E620",
                "item_name" => "L-Glutamic Acid",
                "info" => "Miscellaneous - Flavour Enhancers",
                "status" =>
                    "MUSHBOOH: Halal if it is from plant protein, Haram if it is from pig protein ",
            ],
            [
                "code" => "E621",
                "item_name" => "Monosodium Glutamate (MSG)",
                "info" => "Miscellaneous - Flavour Enhancers",
                "status" =>
                    "MUSHBOOH: Halal if all ingredients including culture media to grow culture from Halal source, Haram if media is from pork fat",
            ],
            [
                "code" => "E622",
                "item_name" => "Monopotassium Glutamate",
                "info" => "Miscellaneous - Flavour Enhancers",
                "status" =>
                    "MUSHBOOH: Halal if all ingredients including culture media to grow culture from Halal source, Haram if media is from pork fat",
            ],
            [
                "code" => "E623",
                "item_name" => "Calcium Glutamate",
                "info" => "Miscellaneous - Flavour Enhancers",
                "status" =>
                    "MUSHBOOH: Halal if all ingredients including culture media to grow culture from Halal source, Haram if media is from pork fat",
            ],
            [
                "code" => "E627",
                "item_name" => "Sodium Guanylate",
                "info" => "Miscellaneous - Flavour Enhancers",
                "status" =>
                    "MUSHBOOH: Halal if it is obtained from sardines. Mushbooh if it is made from brewer yeast extract, a by-product of beer making.",
            ],
            [
                "code" => "E631",
                "item_name" => "Sodium Inosinate",
                "info" =>
                    "Miscellaneous - Flavour Enhancers. In Europe if it is obtained from non alcoholic fermantation by bacteria on sugar or from sugarcane itself then it is Halal but if it is obtained from Torula yeast grown on alcohol then disodium Inosinate is not Halal. It is Halal in USA and Canada. Disodium Inosinate is used in Europe as flavor enhancer used in soups, gravies, sauces, fish and seafoods. Although it is a nucleotide but it is obtained through bacterial non- alcoholic fermantation on sugar or from sugarcane itself. It should not be confused with nucleotide from Torula yeast which grown alcohol or sugar cane which is used in infant baby formula.",
                "status" =>
                    "MUSHBOOH: Halal if it is obtained from sardines. Mushbooh if it is made from brewer yeast extract, a by-product of beer making. Haram if it is extracted from pig meat.",
            ],
            [
                "code" => "E635",
                "item_name" => "Sodium5-Ribonucleotide",
                "info" => "Miscellaneous - Flavour Enhancers",
                "status" =>
                    "MUSHBOOH: Halal if it is obtained from sardines. Mushbooh if it is made from brewer yeast extract, a by-product of beer making. Haram if it is extracted from pig meat.",
            ],
            [
                "code" => "E904",
                "item_name" => "Shellac",
                "info" => "Miscellaneous - Glazing Agents",
                "status" =>
                    "MUSHBOOH: Halal if no if it is not treated with alcohol, two types of shellac is available, the Halal type  is not treated with alcohol but other type is treated with alcohol. A gummy secretion material from the pores of a insect Coccus lacca that feed on Palas trees in India and South Asia. This gummy material is called Lac. Manufactured by Indian companies.",
            ],
            [
                "code" => "E907",
                "item_name" => "Refined Microcrystalline Wax",
                "info" => "Miscellaneous - Glazing Agents",
                "status" =>
                    "MUSHBOOH: Halal if obtained from plant fat wax. Haram if it is obtained from pork fat wax ",
            ],
            [
                "code" => "E920",
                "item_name" => "L-Cysteine Hydrochloride",
                "info" => "Miscellaneous - Compounds used to treat Flour",
                "status" =>
                    "MUSHBOOH: Haram if it is obtained from human hair, Halal if it is made from Halal synthetic material. The third source is from chicken/duck feathers. There is difference of opinions among different Islamic scholars. One school of ulema says it is Halal the other says not Halal.  ",
            ]
        ];

        foreach ($haramCode as $key => $item) {
            \App\Models\Quran\HaramCode\HaramCode::query()->create([
                'code' => $item['code'],
                'name' => $item['item_name'],
                'description' => $item['info'],
                'status_info' => $item['status']
            ]);
        }
    }
}
